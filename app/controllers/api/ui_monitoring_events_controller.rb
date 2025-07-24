module Api
  class UiMonitoringEventsController < ApplicationController
    # Skip CSRF protection for API endpoints but implement other security measures
    skip_before_action :verify_authenticity_token, only: [:create]
    before_action :validate_request_origin
    
    # Rate limiting to prevent abuse
    include ApiRateLimiter
    rate_limit :create, limit: 100, period: 1.hour
    
    def create
      @event = UiMonitoringEvent.new(event_params)
      
      # Associate with user if authenticated
      @event.user = current_user if user_signed_in?
      
      # Track session and request information
      @event.session_id = session.id
      @event.ip_address = request.remote_ip
      @event.user_agent = request.user_agent
      
      # Anonymize IP address for privacy (keep only first two octets)
      anonymize_ip_address
      
      if @event.save
        process_event(@event)
        render json: { status: 'success', event_id: @event.id }
      else
        render json: { status: 'error', errors: @event.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    private
    
    def event_params
      params.require(:ui_monitoring_event).permit(:event_type, data: {})
    end
    
    def process_event(event)
      # Check if this event should trigger an alert
      if should_alert?(event)
        UiMonitoringAlertJob.perform_later(event.id)
      end
    end
    
    def should_alert?(event)
      case event.event_type
      when 'ui_error'
        # Alert on critical errors or errors affecting multiple users
        similar_errors = UiMonitoringEvent
          .where(event_type: 'ui_error')
          .where("data->>'error_type' = ?", event.data['error_type'])
          .where('created_at > ?', 1.hour.ago)
          .count
          
        similar_errors >= 3
      when 'performance_metric'
        # Alert on significant performance issues
        event.data['metric_name'] == 'theme_switch_duration' && 
          event.data['value'].to_f > 2000 # More than 2 seconds
      else
        false
      end
    end
    
    def validate_request_origin
      # Only allow requests from our own domain or trusted sources
      valid_origins = [request.base_url]
      
      # Add any additional trusted origins from configuration
      if Rails.configuration.respond_to?(:trusted_origins)
        valid_origins.concat(Rails.configuration.trusted_origins)
      end
      
      request_origin = request.headers['Origin'] || request.headers['Referer']
      
      unless request_origin.blank? || valid_origins.any? { |origin| request_origin.start_with?(origin) }
        render json: { error: 'Unauthorized origin' }, status: :forbidden
        return false
      end
    end
    
    def anonymize_ip_address
      return unless @event.ip_address.present?
      
      # Keep only first two octets for IPv4 addresses
      if @event.ip_address =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/
        octets = @event.ip_address.split('.')
        @event.ip_address = "#{octets[0]}.#{octets[1]}.0.0"
      elsif @event.ip_address.include?(':') # IPv6
        # For IPv6, keep only the network portion
        @event.ip_address = @event.ip_address.gsub(/:[^:]+:[^:]+$/, ':0:0')
      end
    end
  end
end