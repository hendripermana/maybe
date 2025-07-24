require "test_helper"

class SentryIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in @admin
    
    # Mock Sentry
    @sentry_event_id = "abc123"
    Sentry.stubs(:capture_message).returns(OpenStruct.new(event_id: @sentry_event_id))
  end
  
  test "UI error events are sent to Sentry" do
    # Arrange
    error_data = {
      error_type: "TypeError",
      message: "Cannot read property of undefined",
      stack: "Error: Test\n    at test.js:1:1",
      context: JSON.generate({ componentName: "TestComponent" }),
      url: "http://localhost:3000/test",
      user_agent: "Mozilla/5.0"
    }
    
    # Act
    post "/monitoring/ui_error", params: error_data
    
    # Assert
    assert_response :success
    
    # Verify the event was created
    event = UiMonitoringEvent.last
    assert_equal "ui_error", event.event_type
    assert_equal "TypeError", event.data["error_type"]
    
    # Verify Sentry was called
    assert_equal @sentry_event_id, event.data["sentry_event_id"]
    
    # Verify the response includes the Sentry event ID
    response_json = JSON.parse(response.body)
    assert_equal @sentry_event_id, response_json["sentry_event_id"]
  end
  
  test "UI monitoring alert includes Sentry link" do
    # Arrange
    event = UiMonitoringEvent.create!(
      event_type: "ui_error",
      data: {
        error_type: "TypeError",
        message: "Test error",
        component_name: "TestComponent"
      },
      user_id: @admin.id,
      session_id: "test_session",
      user_agent: "test_agent",
      ip_address: "127.0.0.1"
    )
    
    # Mock similar errors to trigger alert
    UiMonitoringEvent.stubs(:where).returns(OpenStruct.new(count: 3))
    
    # Mock email delivery
    email = OpenStruct.new
    MonitoringMailer.stubs(:ui_monitoring_alert).returns(email)
    email.stubs(:deliver_later)
    
    # Mock Slack notification
    SlackNotifier.stubs(:notify)
    
    # Act
    UiMonitoringAlertJob.new.perform(event.id)
    
    # Assert
    # Verify the event was updated with Sentry event ID
    event.reload
    assert_equal @sentry_event_id, event.data["sentry_event_id"]
    
    # Verify Sentry was called with the correct parameters
    Sentry.expects(:capture_message).with(
      "UI Error Alert: TypeError",
      has_entry(tags: has_entry(ui_monitoring: true))
    ).returns(OpenStruct.new(event_id: @sentry_event_id))
    
    # Run again to verify the expectations
    UiMonitoringAlertJob.new.perform(event.id)
  end
end