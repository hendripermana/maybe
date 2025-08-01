class MonitoringMailerPreview < ActionMailer::Preview
  def ui_monitoring_alert
    MonitoringMailer.ui_monitoring_alert(
      "Test Alert Title",
      "This is a test alert message with some details.\n\nIt includes multiple lines of text to show formatting.",
      :error,
      :error
    )
  end

  def performance_alert
    MonitoringMailer.ui_monitoring_alert(
      "Performance Alert",
      "Theme switching is taking longer than expected.\n\nAverage duration: 450ms\nThreshold: 300ms",
      :performance,
      :warning
    )
  end

  def accessibility_alert
    MonitoringMailer.ui_monitoring_alert(
      "Accessibility Issues Detected",
      "3 new accessibility issues reported in the last 24 hours:\n\n- Missing alt text on images\n- Color contrast issues\n- Keyboard navigation problems",
      :accessibility,
      :error
    )
  end
end
