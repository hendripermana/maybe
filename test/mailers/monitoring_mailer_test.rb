require "test_helper"

class MonitoringMailerTest < ActionMailer::TestCase
  test "ui_monitoring_alert" do
    # Send the email
    email = MonitoringMailer.ui_monitoring_alert(
      "Test Alert",
      "This is a test alert message",
      :error,
      :error
    )

    # Test the email content
    assert_emails 1 do
      email.deliver_now
    end

    # Test the email headers
    assert_equal [ "admin@maybe.local" ], email.to
    assert_equal "[UI Monitoring Alert] Test Alert", email.subject

    # Test the email body
    assert_includes email.html_part.body.to_s, "Test Alert"
    assert_includes email.html_part.body.to_s, "This is a test alert message"
    assert_includes email.text_part.body.to_s, "Test Alert"
    assert_includes email.text_part.body.to_s, "This is a test alert message"
  end
end
