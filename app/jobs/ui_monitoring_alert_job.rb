class UiMonitoringAlertJob < ApplicationJob
  queue_as :default

  def perform(event_id = nil)
    if event_id.present?
      # Process a specific event
      process_specific_event(event_id)
    else
      # Run regular checks
      check_theme_switching_performance
      check_component_errors
      check_accessibility_issues
      check_performance_regressions
    end
  end

  def process_specific_event(event_id)
    event = UiMonitoringEvent.find_by(id: event_id)
    return unless event

    case event.event_type
    when "ui_error"
      handle_error_alert(event)
    when "performance_metric"
      handle_performance_alert(event)
    end
  end

  def handle_error_alert(event)
    error_type = event.data["error_type"]
    component_name = event.data["component_name"]
    message = event.data["message"]

    # Count similar errors
    similar_errors = UiMonitoringEvent
      .where(event_type: "ui_error")
      .where("data->>'error_type' = ?", error_type)
      .where("created_at > ?", 1.hour.ago)
      .count

    if similar_errors >= 3
      alert_message = "UI Error Alert: #{error_type} in #{component_name || 'unknown component'} (#{similar_errors} occurrences in the last hour)\n"
      alert_message += "Message: #{message}\n"

      send_alert(
        "UI Error Alert: #{error_type}",
        alert_message,
        :error,
        :error,
        event
      )
    end
  end

  def handle_performance_alert(event)
    metric_name = event.data["metric_name"]
    value = event.data["value"]

    if metric_name == "theme_switch_duration" && value.to_f > 2000
      alert_message = "Performance Alert: #{metric_name} - #{value}ms exceeds threshold\n"

      send_alert(
        "Performance Alert: #{metric_name}",
        alert_message,
        :performance,
        :warning,
        event
      )
    end
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
      component_errors = UiMonitoringEvent.component_errors.where("created_at > ?", 24.hours.ago)

      return if component_errors.empty?

      # Group errors by component
      error_summary = component_errors.group("data->>'componentName'")
                                     .select("data->>'componentName' as component_name, COUNT(*) as count")
                                     .order("count DESC")

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
      accessibility_issues = UserFeedback.where(feedback_type: "accessibility_issue")
                                        .where("created_at > ?", 24.hours.ago)

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
      performance_issues = UiMonitoringEvent.where(event_type: "performance_issue")
                                           .where("created_at > ?", 24.hours.ago)

      return if performance_issues.empty?

      # Group by issue type
      issue_summary = performance_issues.group("data->>'issue_type'")
                                       .select("data->>'issue_type' as issue_type, COUNT(*) as count")
                                       .order("count DESC")

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

    def send_alert(title, message, category, severity, event = nil)
      # Generate a unique key for this alert for throttling
      alert_key = "#{category}:#{title.parameterize}"

      # Check if this alert should be throttled
      throttler = AlertThrottler.new
      if throttler.throttled?(alert_key, category)
        Rails.logger.info "[UI Monitoring Alert] Throttled alert: #{title}"
        return
      end

      # Log the alert
      Rails.logger.send(severity, "[UI Monitoring Alert] #{title}: #{message}")

      # Send to Sentry if available
      sentry_event_id = nil
      if defined?(Sentry)
        sentry_event = Sentry.capture_message(
          title,
          level: severity,
          tags: {
            category: category,
            ui_monitoring: true,
            ui_monitoring_event_id: event&.id
          },
          extra: {
            message: message,
            ui_monitoring_event_id: event&.id
          }
        )
        sentry_event_id = sentry_event.event_id if sentry_event

        # Update the UI monitoring event with the Sentry event ID if available
        if event && sentry_event_id
          event.update(data: event.data.merge(sentry_event_id: sentry_event_id))
        end
      end

      # Add monitoring dashboard link to the message
      dashboard_url = Rails.application.routes.url_helpers.monitoring_events_url(
        host: ENV["APPLICATION_HOST"] || "localhost:3000",
        protocol: ENV["APPLICATION_PROTOCOL"] || "http"
      )

      # Add Sentry link if available
      if sentry_event_id && ENV["SENTRY_ORGANIZATION"] && ENV["SENTRY_PROJECT"]
        sentry_url = "https://sentry.io/organizations/#{ENV['SENTRY_ORGANIZATION']}/issues/?project=#{ENV['SENTRY_PROJECT']}&query=event.id%3A#{sentry_event_id}"
        message += "\n\nView in Sentry: #{sentry_url}"
      end

      message += "\n\nView in Monitoring Dashboard: #{dashboard_url}"

      # Send email notification
      MonitoringMailer.ui_monitoring_alert(title, message, category, severity).deliver_later

      # Send Slack notification if configured
      SlackNotifier.notify(title, message, category, severity)
    end
end
