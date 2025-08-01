# Integration test for data privacy functionality
require "test_helper"

class DataPrivacyIntegrationTest < ActionDispatch::IntegrationTest
  test "data privacy service anonymizes IP addresses correctly" do
    # Test IPv4 anonymization
    ipv4 = "192.168.1.100"
    anonymized_ipv4 = DataPrivacyService.send(:anonymize_ip_address, ipv4)
    assert_equal "192.168.0.0", anonymized_ipv4

    # Test IPv6 anonymization
    ipv6 = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
    anonymized_ipv6 = DataPrivacyService.send(:anonymize_ip_address, ipv6)
    assert anonymized_ipv6.end_with?(":0:0")
  end

  test "data privacy service anonymizes user agents correctly" do
    chrome_ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    anonymized = DataPrivacyService.send(:anonymize_user_agent, chrome_ua)
    assert_equal "Chrome (anonymized)", anonymized

    firefox_ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:89.0) Gecko/20100101 Firefox/89.0"
    anonymized = DataPrivacyService.send(:anonymize_user_agent, firefox_ua)
    assert_equal "Firefox (anonymized)", anonymized
  end

  test "data privacy service sanitizes messages with PII" do
    message = "Contact me at john.doe@example.com or call 555-123-4567. My card is 4111-1111-1111-1111 and SSN is 123-45-6789"
    sanitized = DataPrivacyService.send(:sanitize_message, message)

    assert sanitized.include?("[EMAIL_REDACTED]")
    assert sanitized.include?("[PHONE_REDACTED]")
    assert sanitized.include?("[CARD_REDACTED]")
    assert sanitized.include?("[SSN_REDACTED]")

    assert_not sanitized.include?("john.doe@example.com")
    assert_not sanitized.include?("555-123-4567")
    assert_not sanitized.include?("4111-1111-1111-1111")
    assert_not sanitized.include?("123-45-6789")
  end

  test "data privacy service anonymizes event data" do
    data = {
      "error_type" => "TypeError",
      "message" => "Error occurred",
      "url" => "https://example.com/page?token=secret123",
      "user_agent" => "Mozilla/5.0...",
      "stack" => "Error at line 1",
      "email" => "user@example.com",
      "api_key" => "sk_test_123456789"
    }

    anonymized = DataPrivacyService.send(:anonymize_event_data, data)

    # Sensitive fields should be anonymized
    assert_equal "[ANONYMIZED]", anonymized["user_agent"]
    assert_equal "[ANONYMIZED]", anonymized["stack"]
    assert_equal "[ANONYMIZED]", anonymized["email"]
    assert_equal "[ANONYMIZED]", anonymized["api_key"]

    # URL should be cleaned
    assert anonymized["url"].include?("https://example.com/page")
    assert_not anonymized["url"].include?("token=secret123")

    # Non-sensitive fields should remain
    assert_equal "TypeError", anonymized["error_type"]
    assert_equal "Error occurred", anonymized["message"]
  end

  test "ui monitoring event model has privacy methods" do
    event = UiMonitoringEvent.new(
      event_type: "ui_error",
      data: { error_type: "TypeError", message: "Test error" },
      session_id: "test_session",
      ip_address: "192.168.1.100"
    )

    assert event.contains_sensitive_data?
    assert_respond_to event, :anonymize!
  end

  test "user feedback model has privacy methods" do
    feedback = UserFeedback.new(
      feedback_type: "bug_report",
      message: "Test feedback with email test@example.com",
      page: "/dashboard"
    )

    assert feedback.contains_pii?
    assert_respond_to feedback, :anonymize!
  end

  test "data privacy purge job exists and is scheduled" do
    assert defined?(DataPrivacyPurgeJob)
    assert_respond_to DataPrivacyPurgeJob, :perform_later

    # Check if it's in the schedule
    schedule_config = YAML.load_file(Rails.root.join("config", "schedule.yml"))
    assert schedule_config.key?("data_privacy_purge")
    assert_equal "DataPrivacyPurgeJob", schedule_config["data_privacy_purge"]["class"]
  end
end
