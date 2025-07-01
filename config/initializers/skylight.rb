if Rails.env.production?
  Skylight.start!(
    daemon: {
      pidfile_path: "/tmp/skylight.pid"
    }
  )
end
