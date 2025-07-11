if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.environment = ENV["RAILS_ENV"]
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.enabled_environments = %w[production]
    config.traces_sample_rate = 0.25
    config.profiles_sample_rate = 0.25
    config.profiler_class = Sentry::Vernier::Profiler
    config.debug = true
  end
end