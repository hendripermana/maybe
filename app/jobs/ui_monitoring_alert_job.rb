class UiMonitoringAlertJob < ApplicationJob
  queue_as :default

  def perform
    check_theme_switching_performance
    check_component_errors
    check_accessibility_issues
    check_performance_regressions
  end

  private

  def check_theme_switching_performance
    # Get average theme switching time for the last day
    avg_duration = UiMonitoringEvent.theme_switch_performance(24.hours)
    
    return unless avg_duration.present?
    
    # Alert if average theme switching time is over 300ms
    if avg_duration > 300
      send_alert(
        "Theme Switching Performance Alert",
        "Average theme switching time is #{avg_duration.round(2)}ms, which exceeds the 300ms threshold.",
        :performance,
        :warning
      )
    end
  end

  def check_component_errors
    # Get component errors from the last day
    component_errors = UiMonitoringEvent.component_errors.where('created_at > ?', 24.hours.ago)
    
    return if component_errors.empty?
    
    # Group errors by component
    error_summary = component_errors.group("data->>'componentName'")
                                   .select("data->>'componentName' as component_name, COUNT(*) as count")
                                   .order('count DESC')
    
    if error_summary.any?
      message = "Component errors detected in the last 24 hours:\n\n"
      
      error_summary.each do |error|
        message += "- #{error.component_name}: #{error.count} errors\n"
      end
      
      send_alert(
        "UI Component Error Alert",
        message,
        :error,
        :error
      )
    end
  end

  def check_accessibility_issues
    # Get accessibility feedback from the last day
    accessibility_issues = UserFeedback.where(feedback_type: 'accessibility_issue')
                                      .where('created_at > ?', 24.hours.ago)
    
    return if accessibility_issues.empty?
    
    message = "#{accessibility_issues.count} new accessibility issues reported in the last 24 hours:\n\n"
    
    accessibility_issues.each do |issue|
      message += "- Page: #{issue.page}\n"
      message += "  Message: #{issue.message}\n"
      message += "  Theme: #{issue.theme}\n\n"
    end
    
    send_alert(
      "Accessibility Issues Alert",
      message,
      :accessibility,
      :error
    )
  end

  def check_performance_regressions
    # Get performance issues from the last day
    performance_issues = UiMonitoringEvent.where(event_type: 'performance_issue')
                                         .where('created_at > ?', 24.hours.ago)
    
    return if performance_issues.empty?
    
    # Group by issue type
    issue_summary = performance_issues.group("data->>'issue_type'")
                                     .select("data->>'issue_type' as issue_type, COUNT(*) as count")
                                     .order('count DESC')
    
    if issue_summary.any?
      message = "Performance regressions detected in the last 24 hours:\n\n"
      
      issue_summary.each do |issue|
        message += "- #{issue.issue_type}: #{issue.count} occurrences\n"
      end
      
      send_alert(
        "Performance Regression Alert",
        message,
        :performance,
        :warning
      )
    end
  end

  def send_alert(title, message, category, severity)
    # Log the alert
    Rails.logger.send(severity, "[UI Monitoring Alert] #{title}: #{message}")
    
    # Send to Sentry if available
    if defined?(Sentry)
      Sentry.capture_message(
        title,
        level: severity,
        tags: { category: category },
        extra: { message: message }
      )
    end
    
    # You could also send emails to administrators or create notifications
    # AdminMailer.ui_monitoring_alert(title, message, category, severity).deliver_later
  end
end