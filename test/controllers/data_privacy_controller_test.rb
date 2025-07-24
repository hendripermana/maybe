# Test for DataPrivacyController
require 'test_helper'

class DataPrivacyControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Create test users without fixtures
    @family = Family.create!(name: 'Test Family')
    @user = User.create!(
      email: 'test@example.com',
      password: 'password123',
      family: @family,
      role: 'member'
    )
    @admin = User.create!(
      email: 'admin@example.com',
      password: 'password123',
      family: @family,
      role: 'admin'
    )
    
    # Create test data
    @ui_event = UiMonitoringEvent.create!(
      event_type: 'ui_error',
      data: { error_type: 'TypeError', message: 'Test error' },
      user: @user,
      session_id: 'test_session',
      ip_address: '192.168.1.100'
    )
    
    @feedback = UserFeedback.create!(
      feedback_type: 'bug_report',
      message: 'Test feedback',
      page: '/dashboard',
      user: @user
    )
  end

  test "export returns user data when authenticated" do
    sign_in @user
    
    get data_privacy_export_path
    assert_response :success
    
    get data_privacy_export_path(format: :json)
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal @user.id, json_response['user_id']
    assert json_response['ui_monitoring_events'].present?
    assert json_response['user_feedbacks'].present?
  end

  test "export requires authentication" do
    get data_privacy_export_path
    assert_redirected_to new_session_path
  end

  test "delete_request shows form when GET" do
    sign_in @user
    
    get data_privacy_delete_request_path
    assert_response :success
  end

  test "delete_request processes deletion when POST" do
    sign_in @user
    
    assert_difference -> { UiMonitoringEvent.where(user: @user).count }, -1 do
      assert_difference -> { UserFeedback.where(user: @user).count }, -1 do
        post data_privacy_delete_request_path
      end
    end
    
    assert_redirected_to root_path
    assert_match /data has been anonymized/, flash[:notice]
    
    # Check that data was anonymized, not deleted
    @ui_event.reload
    @feedback.reload
    assert_nil @ui_event.user_id
    assert_nil @feedback.user_id
  end

  test "admin_index shows data privacy overview for admins" do
    sign_in @admin
    
    get data_privacy_admin_path
    assert_response :success
    
    assert_select 'h1', text: 'Data Privacy Administration'
    assert_select '.text-2xl', text: /\d+/ # Should show counts
  end

  test "admin_index requires admin access" do
    sign_in @user
    
    get data_privacy_admin_path
    assert_redirected_to root_path
    assert_match /not authorized/, flash[:alert]
  end

  test "admin_purge triggers data purging for admins" do
    sign_in @admin
    
    # Create old data
    old_event = UiMonitoringEvent.create!(
      event_type: 'ui_error',
      data: { error_type: 'OldError' },
      created_at: 100.days.ago
    )
    
    post data_privacy_admin_purge_path
    assert_redirected_to data_privacy_admin_path
    assert_match /purge completed/, flash[:notice]
    
    # Old data should be deleted
    assert_not UiMonitoringEvent.exists?(old_event.id)
  end

  test "admin_purge requires admin access" do
    sign_in @user
    
    post data_privacy_admin_purge_path
    assert_redirected_to root_path
    assert_match /not authorized/, flash[:alert]
  end

  test "admin_audit shows detailed audit information" do
    sign_in @admin
    
    get data_privacy_admin_audit_path
    assert_response :success
    
    assert_select 'h1', text: 'Data Privacy Audit'
    assert_select 'table'
    assert_select 'td', text: 'UI Monitoring Events'
    assert_select 'td', text: 'User Feedback'
  end

  test "admin_audit returns JSON when requested" do
    sign_in @admin
    
    get data_privacy_admin_audit_path(format: :json)
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.key?('old_ui_monitoring_events')
    assert json_response.key?('old_resolved_feedbacks')
    assert json_response.key?('old_unresolved_feedbacks')
  end

  test "admin_anonymize triggers data anonymization" do
    sign_in @admin
    
    # Ensure we have data that needs anonymization
    assert @ui_event.user_id.present?
    assert @feedback.user_id.present?
    
    post data_privacy_admin_anonymize_path
    assert_redirected_to data_privacy_admin_path
    assert_match /anonymization completed/, flash[:notice]
    
    # Data should be anonymized
    @ui_event.reload
    @feedback.reload
    assert_nil @ui_event.user_id
    assert_nil @feedback.user_id
  end

  test "admin_anonymize requires admin access" do
    sign_in @user
    
    post data_privacy_admin_anonymize_path
    assert_redirected_to root_path
    assert_match /not authorized/, flash[:alert]
  end

  test "admin actions handle errors gracefully" do
    sign_in @admin
    
    # Mock an error in the service
    DataPrivacyService.stub(:purge_old_data, -> { raise StandardError.new("Test error") }) do
      post data_privacy_admin_purge_path
      assert_redirected_to data_privacy_admin_path
      assert_match /purge failed/, flash[:alert]
    end
  end
end