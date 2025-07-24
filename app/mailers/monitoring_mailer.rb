class MonitoringMailer < ApplicationMailer
  # Send UI monitoring alert emails to administrators
  def ui_monitoring_alert(title, message, category, severity)
    @title = title
    @message = message
    @category = category
    @severity = severity
    @timestamp = Time.current
    
    # Get admin email addresses from environment or settings
    admin_emails = ENV.fetch("ADMIN_EMAILS", "admin@maybe.local").split(",")
    
    mail(
      to: admin_emails,
      subject: "[UI Monitoring Alert] #{title}"
    )
  end
end