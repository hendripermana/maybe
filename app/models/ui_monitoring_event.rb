class UiMonitoringEvent < ApplicationRecord
  # Associations
  belongs_to :user, optional: true

  # Validations
  validates :event_type, presence: true

  # Scopes
  scope :errors, -> { where(event_type: 'ui_error') }
  scope :performance_issues, -> { where(event_type: 'performance_issue') }
  scope :theme_related, -> { where("data->>'event_name' = 'theme_switch_started' OR data->>'event_name' = 'theme_switched' OR data->>'event_name' = 'theme_error'") }
  scope :component_errors, -> { where("data->>'error_type' LIKE 'component%'") }
  scope :recent, -> { order(created_at: :desc).limit(100) }

  # Class methods
  def self.performance_metrics_summary(period = 24.hours)
    where(event_type: 'performance_metric')
      .where('created_at > ?', period.ago)
      .group("data->>'metric_name'")
      .select("data->>'metric_name' as metric_name, AVG((data->>'value')::float) as avg_value, COUNT(*) as count")
  end

  def self.error_summary(period = 24.hours)
    where(event_type: 'ui_error')
      .where('created_at > ?', period.ago)
      .group("data->>'error_type'")
      .select("data->>'error_type' as error_type, COUNT(*) as count")
      .order('count DESC')
  end

  def self.theme_switch_performance(period = 24.hours)
    where("data->>'event_name' = 'theme_switched'")
      .where('created_at > ?', period.ago)
      .select("AVG((data->>'duration')::float) as avg_duration")
      .first&.avg_duration
  end

  # Instance methods
  def error_message
    return nil unless event_type == 'ui_error'
    data['message']
  end

  def component_name
    return nil unless data['context'].present?
    context = JSON.parse(data['context']) rescue {}
    context['componentName']
  end

  def browser_info
    user_agent = data['user_agent'] || ''
    if user_agent.include?('Chrome')
      'Chrome'
    elsif user_agent.include?('Firefox')
      'Firefox'
    elsif user_agent.include?('Safari')
      'Safari'
    elsif user_agent.include?('Edge')
      'Edge'
    else
      'Other'
    end
  end
end