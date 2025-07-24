class MonitoringController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:ui_error, :performance_metric, :ui_event, :performance_issue]
  before_action :require_valid_api_key, only: [:ui_error, :performance_metric, :ui_event, :performance_issue]
  before_action :require_admin, only: [:index, :events, :feedback, :resolve_feedback]
  
  include Pagy::Backend
  
  # Dashboard index page
  def index
    @period = params[:period].present? ? params[:period].to_i.hours : 24.hours
    
    @error_summary = UiMonitoringEvent.error_summary(@period)
    @performance_metrics = UiMonitoringEvent.performance_metrics_summary(@period)
    @theme_switch_performance = UiMonitoringEvent.theme_switch_performance(@period)
    
    # Recent events with pagination
    @pagy, @recent_events = pagy(
      UiMonitoringEvent.includes(:user).order(created_at: :desc),
      items: 10
    )
    
    # Feedback summary
    @feedback_summary = UserFeedback.group(:feedback_type)
                                   .select('feedback_type, COUNT(*) as count, COUNT(CASE WHEN resolved = true THEN 1 END) as resolved_count')
    
    # Recent feedback with pagination
    @pagy_feedback, @recent_feedback = pagy(
      UserFeedback.includes(:user).order(created_at: :desc),
      items: 10,
      page_param: :feedback_page
    )
    
    # Alert throttling information
    @throttler = AlertThrottler.new
    @throttled_alerts = {
      error: @throttler.throttled_count(:error),
      performance: @throttler.throttled_count(:performance),
      accessibility: @throttler.throttled_count(:accessibility),
      general: @throttler.throttled_count(:general)
    }
  end
  
  # Events listing with filtering and search
  def events
    @events = UiMonitoringEvent.includes(:user)
    
    # Apply filters
    if params[:event_type].present?
      @events = @events.where(event_type: params[:event_type])
    end
    
    if params[:component].present?
      @events = @events.where("data->>'component_name' = ?", params[:component])
    end
    
    if params[:error_type].present?
      @events = @events.where("data->>'error_type' = ?", params[:error_type])
    end
    
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      @events = @events.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end
    
    # Search functionality
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @events = @events.where("data::text ILIKE ?", search_term)
    end
    
    # Pagination
    @pagy, @events = pagy(@events.order(created_at: :desc), items: 20)
    
    # Get unique values for filters
    @event_types = UiMonitoringEvent.distinct.pluck(:event_type)
    @components = UiMonitoringEvent.where("data->>'component_name' IS NOT NULL")
                                  .distinct
                                  .pluck("data->>'component_name'")
    @error_types = UiMonitoringEvent.where("data->>'error_type' IS NOT NULL")
                                   .distinct
                                   .pluck("data->>'error_type'")
  end
  
  # Feedback listing with filtering and search
  def feedback
    @feedback = UserFeedback.includes(:user)
    
    # Apply filters
    if params[:feedback_type].present?
      @feedback = @feedback.where(feedback_type: params[:feedback_type])
    end
    
    if params[:resolved].present?
      @feedback = @feedback.where(resolved: params[:resolved] == 'true')
    end
    
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      @feedback = @feedback.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end
    
    # Search functionality
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @feedback = @feedback.where("message ILIKE ? OR page ILIKE ?", search_term, search_term)
    end
    
    # Pagination
    @pagy, @feedback = pagy(@feedback.order(created_at: :desc), items: 20)
    
    # Get unique values for filters
    @feedback_types = UserFeedback.feedback_types.keys
  end
  
  # Mark feedback as resolved
  def resolve_feedback
    @feedback = UserFeedback.find(params[:id])
    resolution_notes = params[:resolution_notes]
    
    if @feedback.mark_as_resolved(current_user, resolution_notes)
      redirect_to monitoring_feedback_path, notice: "Feedback marked as resolved"
    else
      redirect_to monitoring_feedback_path, alert: "Failed to resolve feedback: #{@feedback.errors.full_messages.join(', ')}"
    end
  end
  
  # Mark feedback as unresolved
  def unresolve_feedback
    @feedback = UserFeedback.find(params[:id])
    
    if @feedback.update(resolved: false, resolved_at: nil, resolved_by: nil, resolution_notes: nil)
      redirect_to monitoring_feedback_path, notice: "Feedback marked as unresolved"
    else
      redirect_to monitoring_feedback_path, alert: "Failed to update feedback status: #{@feedback.errors.full_messages.join(', ')}"
    end
  end
  
  # Export feedback as CSV
  def export_feedback
    @feedback = UserFeedback.includes(:user)
    
    # Apply the same filters as in the feedback action
    if params[:feedback_type].present?
      @feedback = @feedback.where(feedback_type: params[:feedback_type])
    end
    
    if params[:resolved].present?
      @feedback = @feedback.where(resolved: params[:resolved] == 'true')
    end
    
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      @feedback = @feedback.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end
    
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @feedback = @feedback.where("message ILIKE ? OR page ILIKE ?", search_term, search_term)
    end
    
    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"user-feedback-#{Date.today}.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

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
  
  def require_admin
    unless current_user&.admin?
      flash[:alert] = "You are not authorized to access this page"
      redirect_to root_path
    end
  end
end