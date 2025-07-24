require 'test_helper'

class UiMonitoringAlertJobTest < ActiveSupport::TestCase
  setup do
    # Clear any existing throttling
    AlertThrottler.new.clear_all!
    
    # Create test events
    @error_event = UiMonitoringEvent.create!(
      event_type: 'ui_error',
      data: {
        'error_type' => 'TestError',
        'message' => 'Test error message',
        'component_name' => 'TestComponent'
      }
    )
    
    @performance_event = UiMonitoringEvent.create!(
      event_type: 'performance_metric',
      data: {
        'metric_name' => 'theme_switch_duration',
        'value' => 3000
      }
    )
  end
  
  test "should process error events" do
    # Stub the send_alert method to verify it's called
    UiMonitoringAlertJob.any_instance.expects(:send_alert).with(
      "UI Error Alert: TestError",
      instance_of(String),
      :error,
      :error
    ).once
    
    # Process the event
    job = UiMonitoringAlertJob.new
    job.process_specific_event(@error_event.id)
  end
  
  test "should process performance events" do
    # Stub the send_alert method to verify it's called
    UiMonitoringAlertJob.any_instance.expects(:send_alert).with(
      "Performance Alert: theme_switch_duration",
      instance_of(String),
      :performance,
      :warning
    ).once
    
    # Process the event
    job = UiMonitoringAlertJob.new
    job.process_specific_event(@performance_event.id)
  end
  
  test "should throttle repeated alerts" do
    # Stub the AlertThrottler to simulate throttling
    AlertThrottler.any_instance.stubs(:throttled?).returns(false, true)
    
    # The first alert should be sent
    UiMonitoringAlertJob.any_instance.expects(:send_alert).once
    
    job = UiMonitoringAlertJob.new
    job.process_specific_event(@error_event.id)
    
    # The second alert should be throttled and not sent
    UiMonitoringAlertJob.any_instance.expects(:send_alert).never
    
    job = UiMonitoringAlertJob.new
    job.process_specific_event(@error_event.id)
  end
  
  test "should run periodic checks" do
    # Stub the check methods to verify they're called
    UiMonitoringAlertJob.any_instance.expects(:check_theme_switching_performance).once
    UiMonitoringAlertJob.any_instance.expects(:check_component_errors).once
    UiMonitoringAlertJob.any_instance.expects(:check_accessibility_issues).once
    UiMonitoringAlertJob.any_instance.expects(:check_performance_regressions).once
    
    # Run the job without a specific event ID
    job = UiMonitoringAlertJob.new
    job.perform
  end
end