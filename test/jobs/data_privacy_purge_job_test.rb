# Test for DataPrivacyPurgeJob
require 'test_helper'

class DataPrivacyPurgeJobTest < ActiveJob::TestCase
  setup do
    # Create old test data that should be purged
    @old_event = UiMonitoringEvent.create!(
      event_type: 'ui_error',
      data: { error_type: 'OldError', message: 'Old error' },
      created_at: 100.days.ago
    )
    
    @old_resolved_feedback = UserFeedback.create!(
      feedback_type: 'bug_report',
      message: 'Old resolved feedback',
      page: '/test',
      resolved: true,
      resolved_at: 400.days.ago,
      created_at: 400.days.ago
    )
    
    @old_unresolved_feedback = UserFeedback.create!(
      feedback_type: 'bug_report',
      message: 'Very old unresolved feedback',
      page: '/test',
      resolved: false,
      created_at: 800.days.ago
    )
    
    # Create recent data that should NOT be purged
    @recent_event = UiMonitoringEvent.create!(
      event_type: 'ui_error',
      data: { error_type: 'RecentError', message: 'Recent error' },
      created_at: 1.day.ago
    )
    
    @recent_feedback = UserFeedback.create!(
      feedback_type: 'bug_report',
      message: 'Recent feedback',
      page: '/test',
      resolved: false,
      created_at: 1.day.ago
    )
  end

  test "perform purges old data successfully" do
    # Verify old data exists before job
    assert UiMonitoringEvent.exists?(@old_event.id)
    assert UserFeedback.exists?(@old_resolved_feedback.id)
    assert UserFeedback.exists?(@old_unresolved_feedback.id)
    
    # Verify recent data exists
    assert UiMonitoringEvent.exists?(@recent_event.id)
    assert UserFeedback.exists?(@recent_feedback.id)
    
    # Perform the job
    perform_enqueued_jobs do
      DataPrivacyPurgeJob.perform_later
    end
    
    # Verify old data was purged
    assert_not UiMonitoringEvent.exists?(@old_event.id)
    assert_not UserFeedback.exists?(@old_resolved_feedback.id)
    assert_not UserFeedback.exists?(@old_unresolved_feedback.id)
    
    # Verify recent data was preserved
    assert UiMonitoringEvent.exists?(@recent_event.id)
    assert UserFeedback.exists?(@recent_feedback.id)
  end

  test "perform logs successful purge" do
    # Capture log output
    log_output = capture_log do
      perform_enqueued_jobs do
        DataPrivacyPurgeJob.perform_later
      end
    end
    
    assert_match /Starting automated data privacy purge/, log_output
    assert_match /Data privacy purge completed successfully/, log_output
  end

  test "perform handles errors gracefully" do
    # Mock DataPrivacyService to raise an error
    DataPrivacyService.stub(:purge_old_data, -> { raise StandardError.new("Test error") }) do
      assert_raises StandardError do
        perform_enqueued_jobs do
          DataPrivacyPurgeJob.perform_later
        end
      end
    end
  end

  test "perform logs errors when purge fails" do
    # Mock DataPrivacyService to raise an error
    DataPrivacyService.stub(:purge_old_data, -> { raise StandardError.new("Test error") }) do
      log_output = capture_log do
        assert_raises StandardError do
          perform_enqueued_jobs do
            DataPrivacyPurgeJob.perform_later
          end
        end
      end
      
      assert_match /Data privacy purge failed: Test error/, log_output
    end
  end

  test "job is queued with correct queue" do
    assert_enqueued_with(job: DataPrivacyPurgeJob, queue: 'default') do
      DataPrivacyPurgeJob.perform_later
    end
  end

  private

  def capture_log
    original_logger = Rails.logger
    log_output = StringIO.new
    Rails.logger = Logger.new(log_output)
    
    yield
    
    log_output.string
  ensure
    Rails.logger = original_logger
  end
end