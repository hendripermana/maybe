require "test_helper"

class Api::UiMonitoringEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:regular_user)
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
    @performance_data = {
      ui_monitoring_event: {
        event_type: "performance_metric",
        data: {
          metric_name: "theme_switch_duration",
          value: 1500.5,
          event_name: "theme_switched"
        }
      }
    }
  end

  # Basic functionality tests
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
    assert event.ip_address.present?
    assert event.user_agent.present?
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

  test "should create performance metric event" do
    assert_difference("UiMonitoringEvent.count") do
      post api_ui_monitoring_events_url, params: @performance_data, as: :json
    end

    assert_response :success

    event = UiMonitoringEvent.last
    assert_equal "performance_metric", event.event_type
    assert_equal "theme_switch_duration", event.data["metric_name"]
    assert_equal 1500.5, event.data["value"]
  end

  # Validation tests
  test "should reject invalid event data" do
    post api_ui_monitoring_events_url, params: { ui_monitoring_event: { data: {} } }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "error", json_response["status"]
    assert json_response["errors"].present?
  end

  test "should require event_type" do
    invalid_data = @event_data.deep_dup
    invalid_data[:ui_monitoring_event].delete(:event_type)

    post api_ui_monitoring_events_url, params: invalid_data, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Event type can't be blank"
  end

  test "should handle malformed JSON data" do
    post api_ui_monitoring_events_url,
         params: '{"invalid": json}',
         headers: { "Content-Type" => "application/json" }

    assert_response :bad_request
  end

  # Security tests
  test "should anonymize IPv4 address" do
    post api_ui_monitoring_events_url, params: @event_data, as: :json

    event = UiMonitoringEvent.last
    assert_match(/\d+\.\d+\.0\.0/, event.ip_address)
  end

  test "should anonymize IPv6 address" do
    # Mock the request to have an IPv6 address
    @request.env["REMOTE_ADDR"] = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"

    post api_ui_monitoring_events_url, params: @event_data, as: :json

    event = UiMonitoringEvent.last
    assert_includes event.ip_address, ":0:0"
  end

  test "should validate request origin" do
    # Test with invalid origin
    post api_ui_monitoring_events_url,
         params: @event_data,
         headers: { "Origin" => "https://malicious-site.com" },
         as: :json

    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal "Unauthorized origin", json_response["error"]
  end

  test "should allow requests from same origin" do
    post api_ui_monitoring_events_url,
         params: @event_data,
         headers: { "Origin" => "http://www.example.com" },
         as: :json

    assert_response :success
  end

  test "should allow requests without origin header" do
    post api_ui_monitoring_events_url, params: @event_data, as: :json

    assert_response :success
  end

  # Rate limiting tests (assuming ApiRateLimiter is implemented)
  test "should enforce rate limiting" do
    # This test assumes the rate limiter is properly configured
    # Make 101 requests to exceed the 100 per hour limit
    101.times do |i|
      post api_ui_monitoring_events_url, params: @event_data, as: :json

      if i < 100
        assert_response :success
      else
        # The 101st request should be rate limited
        assert_response :too_many_requests
        break
      end
    end
  end

  # Alert triggering tests
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

  test "should trigger alert for slow theme switching" do
    slow_theme_data = {
      ui_monitoring_event: {
        event_type: "performance_metric",
        data: {
          metric_name: "theme_switch_duration",
          value: 3000.0  # More than 2 seconds
        }
      }
    }

    assert_enqueued_with(job: UiMonitoringAlertJob) do
      post api_ui_monitoring_events_url, params: slow_theme_data, as: :json
    end
  end

  test "should not trigger alert for fast theme switching" do
    fast_theme_data = {
      ui_monitoring_event: {
        event_type: "performance_metric",
        data: {
          metric_name: "theme_switch_duration",
          value: 500.0  # Less than 2 seconds
        }
      }
    }

    assert_no_enqueued_jobs(only: UiMonitoringAlertJob) do
      post api_ui_monitoring_events_url, params: fast_theme_data, as: :json
    end
  end

  test "should not trigger alert for non-theme performance metrics" do
    other_metric_data = {
      ui_monitoring_event: {
        event_type: "performance_metric",
        data: {
          metric_name: "page_load_time",
          value: 5000.0  # High value but not theme-related
        }
      }
    }

    assert_no_enqueued_jobs(only: UiMonitoringAlertJob) do
      post api_ui_monitoring_events_url, params: other_metric_data, as: :json
    end
  end

  # Data integrity tests
  test "should preserve complex data structures" do
    complex_data = @event_data.deep_dup
    complex_data[:ui_monitoring_event][:data][:nested] = {
      array: [ 1, 2, 3 ],
      hash: { key: "value" },
      boolean: true,
      null_value: nil
    }

    post api_ui_monitoring_events_url, params: complex_data, as: :json

    assert_response :success
    event = UiMonitoringEvent.last
    assert_equal [ 1, 2, 3 ], event.data["nested"]["array"]
    assert_equal({ "key" => "value" }, event.data["nested"]["hash"])
    assert_equal true, event.data["nested"]["boolean"]
    assert_nil event.data["nested"]["null_value"]
  end

  test "should handle empty data gracefully" do
    empty_data = {
      ui_monitoring_event: {
        event_type: "ui_error",
        data: {}
      }
    }

    post api_ui_monitoring_events_url, params: empty_data, as: :json

    assert_response :success
    event = UiMonitoringEvent.last
    assert_equal({}, event.data)
  end

  # Session and context tests
  test "should capture session information" do
    post api_ui_monitoring_events_url, params: @event_data, as: :json

    event = UiMonitoringEvent.last
    assert_not_nil event.session_id
    assert_not_nil event.user_agent
    assert_not_nil event.ip_address
  end

  test "should handle missing user agent gracefully" do
    @request.env.delete("HTTP_USER_AGENT")

    post api_ui_monitoring_events_url, params: @event_data, as: :json

    assert_response :success
    event = UiMonitoringEvent.last
    assert_nil event.user_agent
  end

  # Error handling tests
  test "should handle database errors gracefully" do
    # Mock a database error
    UiMonitoringEvent.any_instance.stubs(:save).returns(false)
    UiMonitoringEvent.any_instance.stubs(:errors).returns(
      ActiveModel::Errors.new(UiMonitoringEvent.new).tap do |errors|
        errors.add(:base, "Database connection failed")
      end
    )

    post api_ui_monitoring_events_url, params: @event_data, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "error", json_response["status"]
    assert_includes json_response["errors"], "Database connection failed"
  end

  # Content type tests
  test "should accept JSON content type" do
    post api_ui_monitoring_events_url,
         params: @event_data.to_json,
         headers: { "Content-Type" => "application/json" }

    assert_response :success
  end

  test "should accept form data" do
    post api_ui_monitoring_events_url, params: @event_data

    assert_response :success
  end

  # CSRF protection tests
  test "should skip CSRF protection for API endpoints" do
    # This test ensures that API endpoints work without CSRF tokens
    # which is necessary for client-side JavaScript calls
    post api_ui_monitoring_events_url, params: @event_data, as: :json

    assert_response :success
    # If CSRF protection wasn't skipped, this would return 422
  end
end
