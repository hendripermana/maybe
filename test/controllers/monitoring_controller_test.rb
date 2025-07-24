require "test_helper"

class MonitoringControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:admin_user)
    @regular_user = users(:regular_user)
    
    # Create some test data
    5.times do |i|
      UiMonitoringEvent.create!(
        event_type: "ui_error",
        data: {
          error_type: "TypeError",
          message: "Test error #{i}",
          component_name: "TestComponent"
        },
        user: @admin_user,
        session_id: "test-session",
        user_agent: "Mozilla/5.0",
        ip_address: "127.0.0.1"
      )
    end
    
    3.times do |i|
      UiMonitoringEvent.create!(
        event_type: "performance_metric",
        data: {
          metric_name: "theme_switch_duration",
          value: 100 + i * 10,
          event_name: "theme_switched"
        },
        user: @admin_user,
        session_id: "test-session",
        user_agent: "Mozilla/5.0",
        ip_address: "127.0.0.1"
      )
    end
    
    4.times do |i|
      UserFeedback.create!(
        feedback_type: "bug_report",
        message: "Test feedback #{i}",
        page: "/test",
        user: @admin_user,
        browser: "Mozilla/5.0",
        theme: "dark"
      )
    end
  end
  
  test "should redirect non-admin users from dashboard" do
    sign_in @regular_user
    get monitoring_path
    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page", flash[:alert]
  end
  
  test "should allow admin users to access dashboard" do
    sign_in @admin_user
    get monitoring_path
    assert_response :success
    assert_select "h1", "UI Monitoring Dashboard"
  end
  
  test "should show events page with filters" do
    sign_in @admin_user
    get monitoring_events_path
    assert_response :success
    assert_select "h1", "UI Monitoring Events"
    assert_select "select[name='event_type']"
    assert_select "select[name='component']"
  end
  
  test "should filter events by type" do
    sign_in @admin_user
    get monitoring_events_path, params: { event_type: "ui_error" }
    assert_response :success
    assert_select "tr", count: 6 # 5 events + header row
  end
  
  test "should show feedback page with filters" do
    sign_in @admin_user
    get monitoring_feedback_path
    assert_response :success
    assert_select "h1", "User Feedback"
    assert_select "select[name='feedback_type']"
    assert_select "select[name='resolved']"
  end
  
  test "should filter feedback by type" do
    sign_in @admin_user
    get monitoring_feedback_path, params: { feedback_type: "bug_report" }
    assert_response :success
    assert_select "tr", count: 5 # 4 feedback items + header row
  end
  
  test "should resolve feedback" do
    sign_in @admin_user
    feedback = UserFeedback.first
    
    assert_not feedback.resolved
    
    post resolve_feedback_path(feedback)
    
    assert_redirected_to monitoring_feedback_path
    assert_equal "Feedback marked as resolved", flash[:notice]
    
    feedback.reload
    assert feedback.resolved
    assert_equal @admin_user.id, feedback.resolved_by
  end
end