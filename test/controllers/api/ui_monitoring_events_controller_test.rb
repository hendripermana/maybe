require "test_helper"

class Api::UiMonitoringEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @event_data = {
      ui_monitoring_event: {
        event_type: "ui_error",
        data: {
          error_type: "TypeError",
          message: "Cannot read property of undefined",
          stack: "Error: Cannot read property of undefined\n    at test.js:1:1",
          component_name: "TestComponent",
          context: JSON.generate({ page: "/dashboard" }),
          url: "http://localhost:3000/dashboard",
          user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
        }
      }
    }
  end

  test "should create event when not logged in" do
    assert_difference("UiMonitoringEvent.count") do
      post api_ui_monitoring_events_url, params: @event_data, as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "success", json_response["status"]
    assert json_response["event_id"].present?
    
    # Check that the event was saved correctly
    event = UiMonitoringEvent.last
    assert_equal "ui_error", event.event_type
    assert_equal "TypeError", event.data["error_type"]
    assert_equal "TestComponent", event.data["component_name"]
    assert_nil event.user
    assert event.session_id.present?
  end

  test "should create event when logged in" do
    sign_in @user
    
    assert_difference("UiMonitoringEvent.count") do
      post api_ui_monitoring_events_url, params: @event_data, as: :json
    end

    assert_response :success
    
    # Check that the event was associated with the user
    event = UiMonitoringEvent.last
    assert_equal @user, event.user
  end

  test "should anonymize IP address" do
    post api_ui_monitoring_events_url, params: @event_data, as: :json
    
    event = UiMonitoringEvent.last
    assert_match(/\d+\.\d+\.0\.0/, event.ip_address)
  end

  test "should reject invalid event data" do
    post api_ui_monitoring_events_url, params: { ui_monitoring_event: { data: {} } }, as: :json
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "error", json_response["status"]
    assert json_response["errors"].present?
  end

  test "should trigger alert job for critical errors" do
    # Create two previous errors of the same type
    2.times do
      UiMonitoringEvent.create!(
        event_type: "ui_error",
        data: { "error_type" => "TypeError" },
        created_at: 30.minutes.ago
      )
    end
    
    assert_enqueued_with(job: UiMonitoringAlertJob) do
      post api_ui_monitoring_events_url, params: @event_data, as: :json
    end
  end

  test "should not trigger alert job for isolated errors" do
    assert_no_enqueued_jobs(only: UiMonitoringAlertJob) do
      post api_ui_monitoring_events_url, params: @event_data, as: :json
    end
  end
end