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
    result = where("data->>'event_name' = 'theme_switched'")
      .where('created_at > ?', period.ago)
      .average("(data->>'duration')::float")
    result&.to_f
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

  # Data privacy methods
  def anonymize!
    return if data_anonymized?
    
    DataPrivacyService.anonymize_monitoring_event(self)
    update!(data_anonymized: true, anonymized_at: Time.current)
  end

  def contains_sensitive_data?
    return false if data_anonymized?
    return true if user_id.present?
    return true if session_id.present?
    return true if ip_address.present? && !ip_address.end_with?('.0.0')
    return true if user_agent.present? && !user_agent.include?('anonymized')
    
    # Check data field for sensitive information
    if data.present?
      sensitive_keys = %w[user_agent url stack backtrace context email phone_number api_key token]
      return true if (data.keys & sensitive_keys).any?
    end
    
    false
  end

  # Scope for old records that should be purged
  scope :old_records, ->(retention_days = 90) { where('created_at < ?', retention_days.days.ago) }
  
  # Scope for records that need anonymization
  scope :needs_anonymization, -> { where(data_anonymized: false).where.not(user_id: nil).or(where(data_anonymized: false).where.not(session_id: nil)) }
  
  # Scope for anonymized records
  scope :anonymized, -> { where(data_anonymized: true) }
  
  # GDPR compliance methods
  def self.purge_old_records(retention_days = 90)
    old_records(retention_days).delete_all
  end
  
  def self.anonymize_user_data(user)
    where(user: user).find_each(&:anonymize!)
  end
  
  def self.export_user_data(user)
    where(user: user).map do |event|
      {
        id: event.id,
        event_type: event.event_type,
        created_at: event.created_at.iso8601,
        data: DataPrivacyService.send(:anonymize_event_data, event.data || {}),
        session_id: event.session_id,
        user_agent: DataPrivacyService.send(:anonymize_user_agent, event.user_agent),
        ip_address: DataPrivacyService.send(:anonymize_ip_address, event.ip_address)
      }
    end
  end
  
  # Sentry integration methods
  def sentry_event_id
    data['sentry_event_id']
  end
  
  def has_sentry_event?
    sentry_event_id.present?
  end
  
  def sentry_url
    return nil unless has_sentry_event?
    
    # Construct Sentry URL based on environment configuration
    sentry_org = ENV['SENTRY_ORGANIZATION']
    sentry_project = ENV['SENTRY_PROJECT']
    
    return nil unless sentry_org.present? && sentry_project.present?
    
    "https://sentry.io/organizations/#{sentry_org}/issues/?project=#{sentry_project}&query=event.id%3A#{sentry_event_id}"
  end
end