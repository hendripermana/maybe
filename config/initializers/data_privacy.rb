# Data Privacy Configuration Initializer
# Loads data privacy settings and configures the application for GDPR compliance

Rails.application.configure do
  # Load data privacy configuration
  config_file = Rails.root.join('config', 'data_privacy.yml')
  
  if File.exist?(config_file)
    privacy_config = YAML.load_file(config_file)[Rails.env] || YAML.load_file(config_file)
    config.data_privacy = ActiveSupport::OrderedOptions.new
    
    # Set retention periods
    config.data_privacy.retention_periods = ActiveSupport::OrderedOptions.new
    retention_config = privacy_config['retention_periods'] || {}
    config.data_privacy.retention_periods.ui_monitoring_events = retention_config['ui_monitoring_events'] || 90
    config.data_privacy.retention_periods.user_feedbacks_unresolved = retention_config['user_feedbacks_unresolved'] || 730
    config.data_privacy.retention_periods.user_feedbacks_resolved = retention_config['user_feedbacks_resolved'] || 365
    config.data_privacy.retention_periods.session_data = retention_config['session_data'] || 30
    
    # Set anonymization settings
    config.data_privacy.anonymization = ActiveSupport::OrderedOptions.new
    anon_config = privacy_config['anonymization'] || {}
    config.data_privacy.anonymization.auto_anonymize_on_create = anon_config['auto_anonymize_on_create'] || false
    config.data_privacy.anonymization.auto_anonymize_after_days = anon_config['auto_anonymize_after_days'] || 30
    config.data_privacy.anonymization.sensitive_fields = anon_config['sensitive_fields'] || []
    
    # IP anonymization settings
    ip_config = anon_config['ip_anonymization'] || {}
    config.data_privacy.anonymization.ipv4_octets_to_keep = ip_config['ipv4_octets_to_keep'] || 2
    config.data_privacy.anonymization.ipv6_keep_network_only = ip_config['ipv6_keep_network_only'] || true
    
    # GDPR settings
    config.data_privacy.gdpr = ActiveSupport::OrderedOptions.new
    gdpr_config = privacy_config['gdpr'] || {}
    config.data_privacy.gdpr.enabled = gdpr_config['enabled'] || false
    config.data_privacy.gdpr.rights = gdpr_config['rights'] || {}
    config.data_privacy.gdpr.consent = gdpr_config['consent'] || {}
    config.data_privacy.gdpr.breach_notification = gdpr_config['breach_notification'] || {}
    
    # Alert settings
    config.data_privacy.alerts = ActiveSupport::OrderedOptions.new
    alert_config = privacy_config['alerts'] || {}
    config.data_privacy.alerts.retention_violation_threshold = alert_config['retention_violation_threshold'] || 7
    config.data_privacy.alerts.anonymization_failure_alert = alert_config['anonymization_failure_alert'] || true
    config.data_privacy.alerts.sensitive_data_detection_alert = alert_config['sensitive_data_detection_alert'] || true
    
    # Export formats
    config.data_privacy.export_formats = privacy_config['export_formats'] || ['json']
    
    # Audit settings
    config.data_privacy.audit = ActiveSupport::OrderedOptions.new
    audit_config = privacy_config['audit'] || {}
    config.data_privacy.audit.enabled = audit_config['enabled'] || false
    config.data_privacy.audit.audit_log_retention = audit_config['audit_log_retention'] || 2555
    config.data_privacy.audit.operations_to_audit = audit_config['operations_to_audit'] || []
    
    Rails.logger.info "Data privacy configuration loaded successfully"
  else
    Rails.logger.warn "Data privacy configuration file not found at #{config_file}"
    
    # Set default configuration
    config.data_privacy = ActiveSupport::OrderedOptions.new
    config.data_privacy.retention_periods = ActiveSupport::OrderedOptions.new
    config.data_privacy.retention_periods.ui_monitoring_events = 90
    config.data_privacy.retention_periods.user_feedbacks_unresolved = 730
    config.data_privacy.retention_periods.user_feedbacks_resolved = 365
    config.data_privacy.gdpr = ActiveSupport::OrderedOptions.new
    config.data_privacy.gdpr.enabled = false
  end
end

# Configure automatic data anonymization if enabled
if Rails.application.config.data_privacy.anonymization&.auto_anonymize_on_create
  Rails.application.config.after_initialize do
    # Set up automatic anonymization callbacks
    UiMonitoringEvent.after_create :schedule_anonymization
    UserFeedback.after_create :schedule_anonymization
  end
end