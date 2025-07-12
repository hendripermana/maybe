if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.environment = ENV["RAILS_ENV"] || Rails.env
    config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
    config.enabled_environments = %w[production staging]

    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    config.traces_sample_rate = 0.25

    # Set profiles_sample_rate to profile 100%
    # of sampled transactions.
    # We recommend adjusting this value in production.
    config.profiles_sample_rate = 0.25

    config.profiler_class = Sentry::Vernier::Profiler

    # Additional configuration for better error tracking
    config.send_default_pii = false
    config.max_breadcrumbs = 50
    config.release = ENV["APP_VERSION"] || ENV["HEROKU_SLUG_COMMIT"] || "unknown"
    
    # Auto-instrument background jobs
    config.background_worker_threads = 5
    
    # Better exception filtering
    config.excluded_exceptions += [
      'ActionController::RoutingError',
      'ActionController::InvalidAuthenticityToken',
      'ActionDispatch::RemoteIp::IpSpoofAttackError',
      'ActionController::BadRequest',
      'ActionController::UnknownFormat',
      'ActionController::NotImplemented'
    ]

    # Add custom tags
    config.tags = {
      app: "maybe-finance",
      environment: config.environment
    }

    # Enable debug logging for initial setup
    config.debug = true
    config.logger = Rails.logger

    # Configure before_send callback to add user context
    config.before_send = lambda do |event, hint|
      # Only process errors in enabled environments
      return nil unless config.enabled_environments.include?(config.environment)
      
      # Add user context if available
      if defined?(Current) && Current.respond_to?(:user) && Current.user
        event.user = {
          id: Current.user.id,
          email: Current.user.email
        }
      end
      
      # Log successful event capture
      Rails.logger.info "Sentry event captured: #{event.event_id}" if Rails.logger
      
      event
    end
  end
  
  # Log successful Sentry initialization
  Rails.logger.info "Sentry initialized successfully with DSN: #{ENV['SENTRY_DSN'][0..20]}..." if Rails.logger
else
  Rails.logger.warn "Sentry not initialized - SENTRY_DSN environment variable not present" if Rails.logger
end
