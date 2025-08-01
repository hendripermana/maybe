# Test for DataPrivacyService
require "test_helper"

class DataPrivacyServiceTest < ActiveSupport::TestCase
  setup do
    # Create test users without fixtures
    @family = Family.create!(name: "Test Family")
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      family: @family,
      role: "member"
    )
    @admin = User.create!(
      email: "admin@example.com",
      password: "password123",
      family: @family,
      role: "admin"
    )

    # Create test data
    @ui_event = UiMonitoringEvent.create!(
      event_type: "ui_error",
      data: {
        error_type: "TypeError",
        message: "Cannot read property of undefined",
        url: "https://example.com/dashboard?user_id=123",
        user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
        stack: "Error at line 1"
      },
      user: @user,
      session_id: "test_session_123",
      ip_address: "192.168.1.100",
      user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
    )

    @feedback = UserFeedback.create!(
      feedback_type: "bug_report",
      message: "I found a bug with my email john.doe@example.com and phone 555-123-4567",
      page: "/dashboard",
      user: @user,
      browser: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
      theme: "dark"
    )
  end

  test "anonymize_monitoring_event removes sensitive data" do
    original_ip = @ui_event.ip_address
    original_user_agent = @ui_event.user_agent

    DataPrivacyService.anonymize_monitoring_event(@ui_event)
    @ui_event.reload

    # IP should be anonymized
    assert_not_equal original_ip, @ui_event.ip_address
    assert @ui_event.ip_address.end_with?(".0.0")

    # User agent should be anonymized
    assert_not_equal original_user_agent, @ui_event.user_agent
    assert @ui_event.user_agent.include?("anonymized")

    # Data should be anonymized
    assert_equal "[ANONYMIZED_URL]", @ui_event.data["url"]
    assert_equal "[ANONYMIZED]", @ui_event.data["stack"]
  end

  test "anonymize_user_feedback removes PII" do
    original_message = @feedback.message
    original_browser = @feedback.browser

    DataPrivacyService.anonymize_user_feedback(@feedback)
    @feedback.reload

    # Message should have PII removed
    assert_not_equal original_message, @feedback.message
    assert @feedback.message.include?("[EMAIL_REDACTED]")
    assert @feedback.message.include?("[PHONE_REDACTED]")

    # Browser should be anonymized
    assert_not_equal original_browser, @feedback.browser
    assert @feedback.browser.include?("anonymized")
  end

  test "purge_old_data removes old records" do
    # Create old records
    old_event = UiMonitoringEvent.create!(
      event_type: "ui_error",
      data: { error_type: "OldError" },
      created_at: 100.days.ago
    )

    old_feedback = UserFeedback.create!(
      feedback_type: "bug_report",
      message: "Old feedback",
      page: "/test",
      resolved: true,
      resolved_at: 400.days.ago,
      created_at: 400.days.ago
    )

    results = DataPrivacyService.purge_old_data

    # Old records should be deleted
    assert_not UiMonitoringEvent.exists?(old_event.id)
    assert_not UserFeedback.exists?(old_feedback.id)

    # Recent records should remain
    assert UiMonitoringEvent.exists?(@ui_event.id)
    assert UserFeedback.exists?(@feedback.id)

    # Results should show what was deleted
    assert results[:ui_monitoring_events] >= 1
    assert results[:resolved_feedbacks] >= 1
  end

  test "export_user_data returns anonymized user data" do
    data = DataPrivacyService.export_user_data(@user)

    assert_equal @user.id, data[:user_id]
    assert data[:exported_at].present?
    assert data[:ui_monitoring_events].present?
    assert data[:user_feedbacks].present?

    # Check that exported data is anonymized
    event_data = data[:ui_monitoring_events].first
    assert event_data[:data]["url"] != @ui_event.data["url"] # Should be anonymized
    assert event_data[:user_agent].include?("anonymized")

    feedback_data = data[:user_feedbacks].first
    assert feedback_data[:message].include?("[EMAIL_REDACTED]")
    assert feedback_data[:message].include?("[PHONE_REDACTED]")
  end

  test "delete_user_data anonymizes user's data" do
    results = DataPrivacyService.delete_user_data(@user)

    @ui_event.reload
    @feedback.reload

    # User associations should be removed
    assert_nil @ui_event.user_id
    assert_nil @feedback.user_id

    # Data should be anonymized
    assert @ui_event.user_agent.include?("anonymized")
    assert @feedback.message.include?("[EMAIL_REDACTED]")

    # Results should show what was processed
    assert results[:ui_monitoring_events] >= 1
    assert results[:user_feedbacks] >= 1
  end

  test "audit_data_retention identifies old records" do
    # Create old records
    UiMonitoringEvent.create!(
      event_type: "ui_error",
      data: { error_type: "OldError" },
      created_at: 100.days.ago
    )

    UserFeedback.create!(
      feedback_type: "bug_report",
      message: "Old resolved feedback",
      page: "/test",
      resolved: true,
      resolved_at: 400.days.ago,
      created_at: 400.days.ago
    )

    audit = DataPrivacyService.audit_data_retention

    assert audit[:old_ui_monitoring_events] >= 1
    assert audit[:old_resolved_feedbacks] >= 1
  end

  test "anonymize_ip_address properly anonymizes IPv4" do
    ip = "192.168.1.100"
    anonymized = DataPrivacyService.send(:anonymize_ip_address, ip)
    assert_equal "192.168.0.0", anonymized
  end

  test "anonymize_ip_address properly anonymizes IPv6" do
    ip = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
    anonymized = DataPrivacyService.send(:anonymize_ip_address, ip)
    assert anonymized.end_with?(":0:0")
  end

  test "anonymize_user_agent extracts browser type" do
    chrome_ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    anonymized = DataPrivacyService.send(:anonymize_user_agent, chrome_ua)
    assert_equal "Chrome (anonymized)", anonymized

    firefox_ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:89.0) Gecko/20100101 Firefox/89.0"
    anonymized = DataPrivacyService.send(:anonymize_user_agent, firefox_ua)
    assert_equal "Firefox (anonymized)", anonymized
  end

  test "sanitize_message removes various PII patterns" do
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

  test "anonymize_event_data removes sensitive fields" do
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

  test "anonymization tracking works correctly" do
    # Initially not anonymized
    assert_not @ui_event.data_anonymized?
    assert_nil @ui_event.anonymized_at

    # Anonymize the event
    @ui_event.anonymize!

    # Should be marked as anonymized
    assert @ui_event.data_anonymized?
    assert @ui_event.anonymized_at.present?

    # Should not anonymize again
    original_anonymized_at = @ui_event.anonymized_at
    @ui_event.anonymize!
    assert_equal original_anonymized_at, @ui_event.anonymized_at
  end

  test "auto_anonymize_old_data processes old records" do
    # Create old records that need anonymization
    old_event = UiMonitoringEvent.create!(
      event_type: "ui_error",
      data: { error_type: "OldError" },
      user: @user,
      session_id: "old_session",
      created_at: 35.days.ago
    )

    old_feedback = UserFeedback.create!(
      feedback_type: "bug_report",
      message: "Old feedback with email test@example.com",
      page: "/test",
      user: @user,
      created_at: 35.days.ago
    )

    # Mock configuration
    Rails.application.config.data_privacy.anonymization.auto_anonymize_after_days = 30

    results = DataPrivacyService.auto_anonymize_old_data

    old_event.reload
    old_feedback.reload

    # Old records should be anonymized
    assert old_event.data_anonymized?
    assert old_feedback.data_anonymized?

    # Results should show what was processed
    assert results[:ui_monitoring_events] >= 1
    assert results[:user_feedbacks] >= 1
  end

  test "needs_anonymization scope works correctly" do
    # Create records that need anonymization
    needs_anon_event = UiMonitoringEvent.create!(
      event_type: "ui_error",
      data: { error_type: "Error" },
      user: @user,
      session_id: "test_session"
    )

    needs_anon_feedback = UserFeedback.create!(
      feedback_type: "bug_report",
      message: "Test feedback",
      page: "/test",
      user: @user
    )

    # Create already anonymized records
    anonymized_event = UiMonitoringEvent.create!(
      event_type: "ui_error",
      data: { error_type: "Error" },
      data_anonymized: true,
      anonymized_at: Time.current
    )

    anonymized_feedback = UserFeedback.create!(
      feedback_type: "bug_report",
      message: "Test feedback",
      page: "/test",
      data_anonymized: true,
      anonymized_at: Time.current
    )

    # Test scopes
    assert UiMonitoringEvent.needs_anonymization.include?(needs_anon_event)
    assert_not UiMonitoringEvent.needs_anonymization.include?(anonymized_event)

    assert UserFeedback.needs_anonymization.include?(needs_anon_feedback)
    assert_not UserFeedback.needs_anonymization.include?(anonymized_feedback)
  end

  test "contains_sensitive_data detection works" do
    # Event with sensitive data
    sensitive_event = UiMonitoringEvent.create!(
      event_type: "ui_error",
      data: { error_type: "Error" },
      user: @user,
      session_id: "test_session",
      ip_address: "192.168.1.100"
    )

    assert sensitive_event.contains_sensitive_data?

    # Anonymized event should not contain sensitive data
    sensitive_event.update!(data_anonymized: true)
    assert_not sensitive_event.contains_sensitive_data?

    # Feedback with PII
    pii_feedback = UserFeedback.create!(
      feedback_type: "bug_report",
      message: "Contact me at test@example.com",
      page: "/test",
      user: @user
    )

    assert pii_feedback.contains_pii?

    # Anonymized feedback should not contain PII
    pii_feedback.update!(data_anonymized: true)
    assert_not pii_feedback.contains_pii?
  end
end
