Rails.application.configure do
  if Rails.env.production?
    # Disable mini profiler in production to avoid file permission issues
    Rack::MiniProfiler.config.enabled = false
  else
    Rack::MiniProfiler.config.skip_paths = [ "/design-system", "/assets", "/cable", "/manifest", "/favicon.ico", "/hotwire-livereload", "/logo-pwa.png" ]
    Rack::MiniProfiler.config.max_traces_to_show = 50
  end
end
