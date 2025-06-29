# typed: false
# frozen_string_literal: true

Yabeda.configure do
  # This block will be executed periodically, and the results of the block will be sent to the monitoring system.
  # collect do
  #   # For example, you can collect the number of users in the database:
  #   group :my_app do
  #     gauge :users_count, tags: [], comment: "Total number of users in the database"
  #     set :users_count, User.count
  #   end
  # end
end

Yabeda::Prometheus::Mmap.configure do
  # This is the directory where the memory-mapped files will be stored.
  # It must be shared between the application and the metrics exporter sidecar.
  dir ENV.fetch("YABEDA_PROMETHEUS_MMAP_DIR")
end
