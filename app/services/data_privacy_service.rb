# Service for handling data privacy measures for UI monitoring and feedback data
class DataPrivacyService
  # Data retention periods (in days) - loaded from configuration
  def self.retention_periods
    @retention_periods ||= {
      ui_monitoring_events: Rails.application.config.data_privacy&.retention_periods&.ui_monitoring_events || 90,
      user_feedbacks_unresolved: Rails.application.config.data_privacy&.retention_periods&.user_feedbacks_unresolved || 730,
      user_feedbacks_resolved: Rails.application.config.data_privacy&.retention_periods&.user_feedbacks_resolved || 365
    }
  end

  class << self
    # Anonymize sensitive data in monitoring events
    def anonymize_monitoring_event(event)
      return unless event.is_a?(UiMonitoringEvent)
      return if event.data_anonymized?

      # Anonymize IP address (already done in controller, but ensure it's done)
      event.ip_address = anonymize_ip_address(event.ip_address) if event.ip_address.present?

      # Anonymize user agent (keep browser info but remove detailed version info)
      event.user_agent = anonymize_user_agent(event.user_agent) if event.user_agent.present?

      # Anonymize sensitive data in the JSON data field
      if event.data.present?
        event.data = anonymize_event_data(event.data)
      end

      # Clear session ID for privacy
      event.session_id = nil

      event.save! if event.changed?
    end

    # Anonymize sensitive data in user feedback
    def anonymize_user_feedback(feedback)
      return unless feedback.is_a?(UserFeedback)
      return if feedback.data_anonymized?

      # Remove potential PII from message (already done in controller, but ensure it's done)
      feedback.message = sanitize_message(feedback.message) if feedback.message.present?

      # Anonymize browser information
      feedback.browser = anonymize_user_agent(feedback.browser) if feedback.browser.present?

      feedback.save! if feedback.changed?
    end

    # Purge old data based on retention policies
    def purge_old_data
      results = {
        ui_monitoring_events: 0,
        user_feedbacks: 0,
        resolved_feedbacks: 0
      }

      # Purge old UI monitoring events
      cutoff_date = retention_periods[:ui_monitoring_events].days.ago
      deleted_events = UiMonitoringEvent.where('created_at < ?', cutoff_date).delete_all
      results[:ui_monitoring_events] = deleted_events

      # Purge old resolved feedback
      resolved_cutoff = retention_periods[:user_feedbacks_resolved].days.ago
      deleted_resolved = UserFeedback.where(resolved: true)
                                   .where('resolved_at < ?', resolved_cutoff)
                                   .delete_all
      results[:resolved_feedbacks] = deleted_resolved

      # Purge very old unresolved feedback
      feedback_cutoff = retention_periods[:user_feedbacks_unresolved].days.ago
      deleted_feedback = UserFeedback.where(resolved: false)
                                   .where('created_at < ?', feedback_cutoff)
                                   .delete_all
      results[:user_feedbacks] = deleted_feedback

      Rails.logger.info "Data purge completed: #{results}"
      results
    end

    # Export user's data for GDPR compliance
    def export_user_data(user)
      return {} unless user.is_a?(User)

      data = {
        user_id: user.id,
        exported_at: Time.current.iso8601,
        ui_monitoring_events: [],
        user_feedbacks: []
      }

      # Export user's monitoring events (anonymized)
      user.ui_monitoring_events.find_each do |event|
        data[:ui_monitoring_events] << {
          id: event.id,
          event_type: event.event_type,
          created_at: event.created_at.iso8601,
          data: anonymize_event_data(event.data || {}),
          session_id: event.session_id,
          user_agent: anonymize_user_agent(event.user_agent),
          ip_address: anonymize_ip_address(event.ip_address)
        }
      end

      # Export user's feedback
      user.user_feedbacks.find_each do |feedback|
        data[:user_feedbacks] << {
          id: feedback.id,
          feedback_type: feedback.feedback_type,
          message: sanitize_message(feedback.message),
          page: feedback.page,
          theme: feedback.theme,
          browser: anonymize_user_agent(feedback.browser),
          resolved: feedback.resolved,
          created_at: feedback.created_at.iso8601,
          resolved_at: feedback.resolved_at&.iso8601
        }
      end

      data
    end

    # Delete all user's data for GDPR compliance (right to be forgotten)
    def delete_user_data(user)
      return false unless user.is_a?(User)

      results = {
        ui_monitoring_events: 0,
        user_feedbacks: 0
      }

      # Delete or anonymize user's monitoring events
      user.ui_monitoring_events.find_each do |event|
        # For monitoring events, we anonymize rather than delete to preserve system insights
        event.update!(
          user_id: nil,
          session_id: nil,
          user_agent: anonymize_user_agent(event.user_agent),
          ip_address: anonymize_ip_address(event.ip_address),
          data: anonymize_event_data(event.data || {}),
          data_anonymized: true,
          anonymized_at: Time.current
        )
        results[:ui_monitoring_events] += 1
      end

      # For feedback, we can either delete or anonymize based on business needs
      # Here we'll anonymize to preserve insights while removing PII
      user.user_feedbacks.find_each do |feedback|
        feedback.update!(
          user_id: nil,
          message: sanitize_message(feedback.message),
          browser: anonymize_user_agent(feedback.browser),
          data_anonymized: true,
          anonymized_at: Time.current
        )
        results[:user_feedbacks] += 1
      end

      Rails.logger.info "User data deletion/anonymization completed for user #{user.id}: #{results}"
      results
    end

    # Automatically anonymize old data based on configuration
    def auto_anonymize_old_data
      return unless Rails.application.config.data_privacy&.anonymization&.auto_anonymize_after_days
      
      anonymize_after_days = Rails.application.config.data_privacy.anonymization.auto_anonymize_after_days
      cutoff_date = anonymize_after_days.days.ago
      
      results = {
        ui_monitoring_events: 0,
        user_feedbacks: 0
      }
      
      # Anonymize old monitoring events
      UiMonitoringEvent.where(data_anonymized: false)
                       .where('created_at < ?', cutoff_date)
                       .find_each do |event|
        event.anonymize!
        results[:ui_monitoring_events] += 1
      end
      
      # Anonymize old feedback
      UserFeedback.where(data_anonymized: false)
                  .where('created_at < ?', cutoff_date)
                  .find_each do |feedback|
        feedback.anonymize!
        results[:user_feedbacks] += 1
      end
      
      Rails.logger.info "Auto-anonymization completed: #{results}"
      results
    end

    # Check if data retention policies are being followed
    def audit_data_retention
      audit_results = {}

      # Check UI monitoring events
      old_events_count = UiMonitoringEvent.where('created_at < ?', retention_periods[:ui_monitoring_events].days.ago).count
      audit_results[:old_ui_monitoring_events] = old_events_count

      # Check resolved feedback
      old_resolved_count = UserFeedback.where(resolved: true)
                                     .where('resolved_at < ?', retention_periods[:user_feedbacks_resolved].days.ago)
                                     .count
      audit_results[:old_resolved_feedbacks] = old_resolved_count

      # Check very old unresolved feedback
      old_feedback_count = UserFeedback.where(resolved: false)
                                     .where('created_at < ?', retention_periods[:user_feedbacks_unresolved].days.ago)
                                     .count
      audit_results[:old_unresolved_feedbacks] = old_feedback_count
      
      # Check data that needs anonymization
      needs_anon_events = UiMonitoringEvent.needs_anonymization.count
      needs_anon_feedback = UserFeedback.needs_anonymization.count
      audit_results[:events_needing_anonymization] = needs_anon_events
      audit_results[:feedback_needing_anonymization] = needs_anon_feedback

      audit_results
    end

    private

    # Anonymize IP addresses by keeping only network portion
    def anonymize_ip_address(ip_address)
      return nil if ip_address.blank?

      if ip_address =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/
        # IPv4: Keep only first two octets
        octets = ip_address.split('.')
        "#{octets[0]}.#{octets[1]}.0.0"
      elsif ip_address.include?(':')
        # IPv6: Keep only network portion
        ip_address.gsub(/:[^:]+:[^:]+$/, ':0:0')
      else
        # Unknown format, return anonymized placeholder
        'anonymized'
      end
    end

    # Anonymize user agent strings
    def anonymize_user_agent(user_agent)
      return nil if user_agent.blank?

      # Extract basic browser info without detailed version numbers
      case user_agent
      when /Chrome/i
        'Chrome (anonymized)'
      when /Firefox/i
        'Firefox (anonymized)'
      when /Safari/i
        'Safari (anonymized)'
      when /Edge/i
        'Edge (anonymized)'
      when /Opera/i
        'Opera (anonymized)'
      else
        'Unknown Browser (anonymized)'
      end
    end

    # Anonymize event data by removing sensitive information
    def anonymize_event_data(data)
      return {} unless data.is_a?(Hash)

      anonymized_data = data.deep_dup

      # Remove or anonymize sensitive fields
      sensitive_fields = %w[
        user_agent url stack backtrace context
        email phone_number api_key token session_id
      ]

      sensitive_fields.each do |field|
        if anonymized_data[field].present?
          anonymized_data[field] = '[ANONYMIZED]'
        end
      end

      # Anonymize URLs to remove query parameters that might contain sensitive data
      if anonymized_data['url'].present?
        begin
          uri = URI.parse(anonymized_data['url'])
          uri.query = nil
          uri.fragment = nil
          anonymized_data['url'] = uri.to_s
        rescue URI::InvalidURIError
          anonymized_data['url'] = '[ANONYMIZED_URL]'
        end
      end

      # Recursively anonymize nested hashes
      anonymized_data.each do |key, value|
        if value.is_a?(Hash)
          anonymized_data[key] = anonymize_event_data(value)
        elsif value.is_a?(String) && value.length > 500
          # Truncate very long strings that might contain sensitive data
          anonymized_data[key] = "#{value[0..100]}... [TRUNCATED]"
        end
      end

      anonymized_data
    end

    # Sanitize messages to remove PII
    def sanitize_message(message)
      return nil if message.blank?

      sanitized = message.dup

      # Remove email addresses
      sanitized.gsub!(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/, '[EMAIL_REDACTED]')

      # Remove phone numbers
      sanitized.gsub!(/\b(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}\b/, '[PHONE_REDACTED]')

      # Remove potential API keys or tokens (long alphanumeric strings)
      sanitized.gsub!(/\b[A-Za-z0-9_-]{20,}\b/, '[TOKEN_REDACTED]')

      # Remove potential credit card numbers
      sanitized.gsub!(/\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b/, '[CARD_REDACTED]')

      # Remove potential SSNs
      sanitized.gsub!(/\b\d{3}-?\d{2}-?\d{4}\b/, '[SSN_REDACTED]')

      sanitized
    end
  end
end