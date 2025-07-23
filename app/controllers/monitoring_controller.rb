class MonitoringController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:ui_error, :performance_metric, :ui_event, :performance_issue]
  before_action :require_valid_api_key, only: [:ui_error, :performance_metric, :ui_event, :performance_issue]

  # Handle UI errors from client-side
  def ui_error
    log_event("ui_error", monitoring_params)
    
    # Send to Sentry for error tracking
    if defined?(Sentry)
      Sentry.capture_message(
        "UI Error: #{monitoring_params[:error_type]}",
        level: 'error',
        extra: {
          message: monitoring_params[:message],
          context: JSON.parse(monitoring_params[:context] || '{}'),
          url: monitoring_params[:url],
          user_agent: monitoring_params[:user_agent]
        }
      )
    end
    
    head :ok
  end

  # Handle performance metrics
  def performance_metric
    log_event("performance_metric", monitoring_params)
    
    # Send to Skylight for performance tracking
    if defined?(Skylight)
      Skylight.instrument(
        category: "ui.performance",
        title: monitoring_params[:metric_name]
      ) do
        # This block is just to create the event
      end
    end
    
    head :ok
  end

  # Handle general UI events
  def ui_event
    log_event("ui_event", monitoring_params)
    head :ok
  end

  # Handle performance issues
  def performance_issue
    log_event("performance_issue", monitoring_params)
    
    # Send to Sentry for tracking
    if defined?(Sentry)
      Sentry.capture_message(
        "UI Performance Issue: #{monitoring_params[:issue_type]}",
        level: 'warning',
        extra: JSON.parse(monitoring_params[:data] || '{}')
      )
    end
    
    head :ok
  end

  # Endpoint for user feedback collection
  def user_feedback
    feedback = UserFeedback.new(
      page: params[:page],
      feedback_type: params[:feedback_type],
      message: params[:message],
      user_id: current_user&.id,
      browser: request.user_agent,
      theme: params[:theme]
    )
    
    if feedback.save
      render json: { success: true, message: "Thank you for your feedback!" }
    else
      render json: { success: false, errors: feedback.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def monitoring_params
    params.permit(
      :error_type, :message, :stack, :context, :url, :user_agent,
      :metric_name, :value, :event_name, :data, :issue_type
    )
  end

  def log_event(event_type, data)
    # Log to Rails logger
    Rails.logger.info("[UI Monitoring] #{event_type}: #{data.to_json}")
    
    # Store in database for analysis if needed
    UiMonitoringEvent.create!(
      event_type: event_type,
      data: data,
      user_id: current_user&.id,
      session_id: session.id,
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    )
  rescue => e
    Rails.logger.error("Failed to log UI monitoring event: #{e.message}")
  end

  def require_valid_api_key
    # Skip in development for easier testing
    return true if Rails.env.development?
    
    # In production, require API key or user authentication
    unless valid_api_key? || user_signed_in?
      head :unauthorized
      return false
    end
  end

  def valid_api_key?
    # Simple API key validation - in a real app, use a more secure approach
    request.headers['X-API-Key'] == ENV['UI_MONITORING_API_KEY']
  end
end