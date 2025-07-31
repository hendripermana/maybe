# UI Monitoring Alert Configuration Guide

## Overview

The UI Monitoring Alert System automatically detects critical issues and notifies the development team. This guide covers how to configure, customize, and manage alerts for optimal system monitoring.

## Alert Types

### Error-Based Alerts

#### Similar Error Threshold Alert
Triggers when multiple users experience the same error.

**Default Configuration:**
```ruby
# config/initializers/ui_monitoring.rb
Rails.application.config.ui_monitoring.similar_error_threshold = 3
Rails.application.config.ui_monitoring.similar_error_window = 1.hour
```

**Customization:**
- `similar_error_threshold`: Number of similar errors to trigger alert (default: 3)
- `similar_error_window`: Time window to count errors (default: 1 hour)

#### Critical Component Failure Alert
Triggers when critical components fail repeatedly.

**Configuration:**
```ruby
Rails.application.config.ui_monitoring.critical_components = [
  'TransactionList',
  'AccountSummary',
  'Dashboard',
  'AuthenticationForm'
]
Rails.application.config.ui_monitoring.critical_failure_threshold = 2
```

### Performance-Based Alerts

#### Theme Switch Performance Alert
Triggers when theme switching takes too long.

**Configuration:**
```ruby
Rails.application.config.ui_monitoring.theme_switch_threshold = 2000 # milliseconds
Rails.application.config.ui_monitoring.theme_switch_samples = 5 # minimum samples
```

#### Component Render Performance Alert
Triggers when component rendering is slow.

**Configuration:**
```ruby
Rails.application.config.ui_monitoring.render_time_thresholds = {
  'TransactionList' => 1000,  # 1 second
  'Dashboard' => 1500,        # 1.5 seconds
  'default' => 800            # 800ms for other components
}
```

### User Experience Alerts

#### High Error Rate Alert
Triggers when overall error rate exceeds threshold.

**Configuration:**
```ruby
Rails.application.config.ui_monitoring.error_rate_threshold = 0.05 # 5% of sessions
Rails.application.config.ui_monitoring.error_rate_window = 15.minutes
```

#### Feedback Volume Alert
Triggers when feedback volume spikes.

**Configuration:**
```ruby
Rails.application.config.ui_monitoring.feedback_volume_threshold = 10 # per hour
Rails.application.config.ui_monitoring.feedback_spike_multiplier = 3 # 3x normal rate
```

## Notification Channels

### Email Notifications

#### Basic Email Setup
```ruby
# config/initializers/ui_monitoring.rb
Rails.application.config.ui_monitoring.email_notifications = {
  enabled: true,
  recipients: [
    'dev-team@maybe.co',
    'ui-team@maybe.co'
  ],
  sender: 'alerts@maybe.co'
}
```

#### Email Templates
Customize email templates in `app/views/monitoring_mailer/`:

```erb
<!-- app/views/monitoring_mailer/ui_error_alert.html.erb -->
<h2>UI Error Alert</h2>
<p><strong>Error Type:</strong> <%= @error_type %></p>
<p><strong>Component:</strong> <%= @component_name %></p>
<p><strong>Occurrences:</strong> <%= @occurrence_count %> in the last hour</p>
<p><strong>Message:</strong> <%= @error_message %></p>

<h3>Recent Examples:</h3>
<ul>
  <% @recent_events.each do |event| %>
    <li>
      <%= event.created_at.strftime('%H:%M:%S') %> - 
      User: <%= event.user&.email || 'Anonymous' %>
    </li>
  <% end %>
</ul>

<p><a href="<%= monitoring_events_url(host: @host) %>">View in Dashboard</a></p>
```

### Slack Integration

#### Setup Slack Webhook
```ruby
# config/initializers/ui_monitoring.rb
Rails.application.config.ui_monitoring.slack_notifications = {
  enabled: true,
  webhook_url: ENV['SLACK_MONITORING_WEBHOOK'],
  channel: '#ui-alerts',
  username: 'UI Monitor'
}
```

#### Custom Slack Messages
```ruby
# app/services/slack_notifier.rb
class SlackNotifier
  def self.send_ui_alert(alert_data)
    payload = {
      channel: Rails.application.config.ui_monitoring.slack_notifications[:channel],
      username: Rails.application.config.ui_monitoring.slack_notifications[:username],
      icon_emoji: ':warning:',
      attachments: [
        {
          color: alert_severity_color(alert_data[:severity]),
          title: alert_data[:title],
          text: alert_data[:message],
          fields: [
            {
              title: 'Component',
              value: alert_data[:component],
              short: true
            },
            {
              title: 'Error Count',
              value: alert_data[:count],
              short: true
            }
          ],
          actions: [
            {
              type: 'button',
              text: 'View Dashboard',
              url: alert_data[:dashboard_url]
            }
          ]
        }
      ]
    }
    
    send_to_slack(payload)
  end
end
```

### Custom Notification Channels

#### Webhook Notifications
```ruby
# config/initializers/ui_monitoring.rb
Rails.application.config.ui_monitoring.webhook_notifications = {
  enabled: true,
  endpoints: [
    {
      url: 'https://your-webhook-endpoint.com/alerts',
      headers: {
        'Authorization' => 'Bearer your-token',
        'Content-Type' => 'application/json'
      }
    }
  ]
}
```

#### SMS Notifications (via Twilio)
```ruby
Rails.application.config.ui_monitoring.sms_notifications = {
  enabled: true,
  account_sid: ENV['TWILIO_ACCOUNT_SID'],
  auth_token: ENV['TWILIO_AUTH_TOKEN'],
  from_number: ENV['TWILIO_FROM_NUMBER'],
  recipients: ['+1234567890'] # Critical alerts only
}
```

## Alert Severity Levels

### Severity Configuration
```ruby
Rails.application.config.ui_monitoring.severity_levels = {
  critical: {
    color: '#ff0000',
    notification_channels: [:email, :slack, :sms],
    escalation_time: 15.minutes
  },
  high: {
    color: '#ff8800',
    notification_channels: [:email, :slack],
    escalation_time: 1.hour
  },
  medium: {
    color: '#ffaa00',
    notification_channels: [:slack],
    escalation_time: 4.hours
  },
  low: {
    color: '#00aa00',
    notification_channels: [:email],
    escalation_time: 24.hours
  }
}
```

### Severity Rules
```ruby
# app/services/alert_severity_service.rb
class AlertSeverityService
  def self.determine_severity(event)
    case event.event_type
    when 'ui_error'
      if critical_component?(event.data['component_name'])
        :critical
      elsif error_affects_multiple_users?(event)
        :high
      else
        :medium
      end
    when 'performance_metric'
      if severe_performance_issue?(event)
        :high
      else
        :medium
      end
    else
      :low
    end
  end
  
  private
  
  def self.critical_component?(component_name)
    Rails.application.config.ui_monitoring.critical_components.include?(component_name)
  end
  
  def self.error_affects_multiple_users?(event)
    similar_errors = UiMonitoringEvent
      .where(event_type: 'ui_error')
      .where("data->>'error_type' = ?", event.data['error_type'])
      .where('created_at > ?', 1.hour.ago)
      .distinct
      .count(:user_id)
    
    similar_errors >= 3
  end
end
```

## Alert Throttling

### Prevent Alert Spam
```ruby
# config/initializers/ui_monitoring.rb
Rails.application.config.ui_monitoring.alert_throttling = {
  enabled: true,
  same_alert_window: 30.minutes,
  max_alerts_per_hour: 10,
  escalation_multiplier: 2
}
```

### Throttling Implementation
```ruby
# app/services/alert_throttler.rb
class AlertThrottler
  def self.should_send_alert?(alert_key, severity)
    cache_key = "alert_throttle:#{alert_key}"
    last_sent = Rails.cache.read(cache_key)
    
    return true if last_sent.nil?
    
    throttle_window = case severity
    when :critical
      5.minutes
    when :high
      15.minutes
    when :medium
      30.minutes
    else
      1.hour
    end
    
    Time.current - last_sent > throttle_window
  end
  
  def self.record_alert_sent(alert_key)
    cache_key = "alert_throttle:#{alert_key}"
    Rails.cache.write(cache_key, Time.current, expires_in: 24.hours)
  end
end
```

## Environment-Specific Configuration

### Development Environment
```ruby
# config/environments/development.rb
config.ui_monitoring.enabled = true
config.ui_monitoring.alert_notifications = false # Disable actual notifications
config.ui_monitoring.log_alerts = true # Log alerts to console instead
```

### Staging Environment
```ruby
# config/environments/staging.rb
config.ui_monitoring.enabled = true
config.ui_monitoring.email_notifications[:recipients] = ['staging-alerts@maybe.co']
config.ui_monitoring.slack_notifications[:channel] = '#staging-alerts'
```

### Production Environment
```ruby
# config/environments/production.rb
config.ui_monitoring.enabled = true
config.ui_monitoring.strict_thresholds = true
config.ui_monitoring.escalation_enabled = true
```

## Custom Alert Rules

### Creating Custom Rules
```ruby
# app/models/ui_monitoring_event.rb
class UiMonitoringEvent < ApplicationRecord
  after_create :check_custom_alert_rules
  
  private
  
  def check_custom_alert_rules
    CustomAlertRule.active.each do |rule|
      if rule.matches?(self)
        UiMonitoringAlertJob.perform_later(self.id, rule.id)
      end
    end
  end
end

# app/models/custom_alert_rule.rb
class CustomAlertRule < ApplicationRecord
  validates :name, presence: true
  validates :conditions, presence: true
  validates :alert_type, presence: true
  
  scope :active, -> { where(active: true) }
  
  def matches?(event)
    # Evaluate conditions against the event
    # This could use a simple DSL or JSON-based rules
    evaluate_conditions(event)
  end
  
  private
  
  def evaluate_conditions(event)
    # Simple example - could be more sophisticated
    conditions.all? do |condition|
      case condition['field']
      when 'event_type'
        event.event_type == condition['value']
      when 'component_name'
        event.data['component_name'] == condition['value']
      when 'error_count'
        similar_event_count(event) >= condition['value'].to_i
      end
    end
  end
end
```

### Rule Configuration UI
```erb
<!-- app/views/monitoring/alert_rules/index.html.erb -->
<div class="alert-rules-management">
  <h2>Custom Alert Rules</h2>
  
  <%= link_to "New Rule", new_monitoring_alert_rule_path, class: "btn btn-primary" %>
  
  <table class="alert-rules-table">
    <thead>
      <tr>
        <th>Name</th>
        <th>Conditions</th>
        <th>Severity</th>
        <th>Status</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <% @alert_rules.each do |rule| %>
        <tr>
          <td><%= rule.name %></td>
          <td><%= rule.conditions_summary %></td>
          <td><%= rule.severity %></td>
          <td>
            <span class="status-badge <%= rule.active? ? 'active' : 'inactive' %>">
              <%= rule.active? ? 'Active' : 'Inactive' %>
            </span>
          </td>
          <td>
            <%= link_to "Edit", edit_monitoring_alert_rule_path(rule) %>
            <%= link_to "Delete", monitoring_alert_rule_path(rule), method: :delete %>
          </td>
        </tr>
      <% end %>
    </tbody>
  </table>
</div>
```

## Alert Testing

### Test Alert Generation
```ruby
# lib/tasks/ui_monitoring.rake
namespace :ui_monitoring do
  desc "Test alert system"
  task test_alerts: :environment do
    puts "Testing UI monitoring alerts..."
    
    # Create test error event
    test_event = UiMonitoringEvent.create!(
      event_type: 'ui_error',
      data: {
        error_type: 'TestError',
        message: 'This is a test alert',
        component_name: 'TestComponent'
      }
    )
    
    # Trigger alert processing
    UiMonitoringAlertJob.perform_now(test_event.id)
    
    puts "Test alert sent!"
  end
end
```

### Alert Validation
```ruby
# test/jobs/ui_monitoring_alert_job_test.rb
require 'test_helper'

class UiMonitoringAlertJobTest < ActiveJob::TestCase
  test "sends alert for critical error" do
    event = ui_monitoring_events(:critical_error)
    
    assert_emails 1 do
      UiMonitoringAlertJob.perform_now(event.id)
    end
  end
  
  test "respects alert throttling" do
    event = ui_monitoring_events(:throttled_error)
    
    # First alert should be sent
    assert_emails 1 do
      UiMonitoringAlertJob.perform_now(event.id)
    end
    
    # Second alert within throttle window should not be sent
    assert_no_emails do
      UiMonitoringAlertJob.perform_now(event.id)
    end
  end
end
```

## Monitoring Alert Performance

### Alert Metrics
Track alert system performance:

```ruby
# app/models/alert_metric.rb
class AlertMetric < ApplicationRecord
  def self.record_alert_sent(alert_type, severity, delivery_time)
    create!(
      alert_type: alert_type,
      severity: severity,
      delivery_time: delivery_time,
      sent_at: Time.current
    )
  end
  
  def self.alert_performance_summary
    group(:alert_type, :severity)
      .select('alert_type, severity, AVG(delivery_time) as avg_delivery_time, COUNT(*) as count')
      .where('sent_at > ?', 24.hours.ago)
  end
end
```

### Alert Dashboard
Monitor alert system health:

```erb
<!-- app/views/monitoring/alerts/dashboard.html.erb -->
<div class="alert-dashboard">
  <h2>Alert System Dashboard</h2>
  
  <div class="metrics-grid">
    <div class="metric-card">
      <h3>Alerts Sent (24h)</h3>
      <div class="metric-value"><%= @alerts_sent_count %></div>
    </div>
    
    <div class="metric-card">
      <h3>Average Delivery Time</h3>
      <div class="metric-value"><%= @avg_delivery_time %>ms</div>
    </div>
    
    <div class="metric-card">
      <h3>Failed Deliveries</h3>
      <div class="metric-value"><%= @failed_deliveries %></div>
    </div>
  </div>
  
  <div class="alert-history">
    <h3>Recent Alerts</h3>
    <table>
      <thead>
        <tr>
          <th>Time</th>
          <th>Type</th>
          <th>Severity</th>
          <th>Delivery Status</th>
        </tr>
      </thead>
      <tbody>
        <% @recent_alerts.each do |alert| %>
          <tr>
            <td><%= alert.sent_at.strftime('%H:%M:%S') %></td>
            <td><%= alert.alert_type %></td>
            <td><%= alert.severity %></td>
            <td>
              <span class="status-badge <%= alert.delivered? ? 'success' : 'failed' %>">
                <%= alert.delivered? ? 'Delivered' : 'Failed' %>
              </span>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
  </div>
</div>
```

## Troubleshooting Alerts

### Common Issues

#### Alerts Not Being Sent
1. Check alert configuration is enabled
2. Verify notification channel credentials
3. Review alert throttling settings
4. Check job queue processing

#### Too Many Alerts
1. Adjust alert thresholds
2. Enable alert throttling
3. Review alert severity rules
4. Consider alert consolidation

#### Missing Critical Alerts
1. Verify critical component configuration
2. Check alert severity rules
3. Review event processing logic
4. Test alert generation manually

### Debug Mode
Enable debug logging for alerts:

```ruby
# config/initializers/ui_monitoring.rb
Rails.application.config.ui_monitoring.debug_alerts = Rails.env.development?

# In alert job
if Rails.application.config.ui_monitoring.debug_alerts
  Rails.logger.debug "Processing alert for event #{event.id}: #{alert_data}"
end
```

## Best Practices

### Alert Configuration
1. **Start Conservative**: Begin with higher thresholds and adjust based on experience
2. **Test Thoroughly**: Test all notification channels before production deployment
3. **Document Changes**: Keep a log of alert configuration changes
4. **Regular Review**: Periodically review and adjust alert rules

### Notification Management
1. **Appropriate Channels**: Use the right channel for each severity level
2. **Clear Messages**: Ensure alert messages are actionable and informative
3. **Avoid Fatigue**: Prevent alert fatigue with proper throttling
4. **Escalation Paths**: Define clear escalation procedures

### Performance Considerations
1. **Async Processing**: Process alerts in background jobs
2. **Efficient Queries**: Optimize database queries for alert detection
3. **Caching**: Cache frequently accessed alert data
4. **Monitoring**: Monitor the alert system itself for performance issues