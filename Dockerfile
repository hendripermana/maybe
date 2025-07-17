# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.4.4
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

ENV TZ=Asia/Jakarta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client libyaml-0-2

# Set production environment
ARG BUILD_COMMIT_SHA
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    SKYLIGHT_AUTHENTICATION=${SKYLIGHT_AUTHENTICATION} \
    BUILD_COMMIT_SHA=${BUILD_COMMIT_SHA}
    
# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get install --no-install-recommends -y build-essential libpq-dev git pkg-config libyaml-dev

# Install application gems
COPY .ruby-version Gemfile Gemfile.lock ./
RUN bundle install

RUN rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

RUN bundle exec bootsnap precompile --gemfile -j 0

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile -j 0 app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Install Skylight gem
RUN bundle exec skylight setup --force

# Create Skylight configuration file if it does not exist
RUN mkdir -p /rails/tmp/skylight && \
    if [ ! -f /home/ubuntu/maybe/config/skylight.yml ]; then \
      mkdir -p /home/ubuntu/maybe/config && \
      echo "production:" > /home/ubuntu/maybe/config/skylight.yml && \
      echo "  enabled: true" >> /home/ubuntu/maybe/config/skylight.yml && \
      echo "  auth_token: <%= ENV[\"SKYLIGHT_AUTHENTICATION\"] %>" >> /home/ubuntu/maybe/config/skylight.yml && \
      echo "  daemon:" >> /home/ubuntu/maybe/config/skylight.yml && \
      echo "    pidfile_path: /rails/tmp/skylight/skylight.pid" >> /home/ubuntu/maybe/config/skylight.yml && \
      echo "    sockdir_path: /rails/tmp/skylight" >> /home/ubuntu/maybe/config/skylight.yml ; \
    fi

# Final stage for app image
FROM base

# Clean up installation packages to reduce image size
RUN rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p /rails/db /rails/log /rails/storage /rails/tmp /rails/tmp/miniprofiler /rails/tmp/skylight && \
    chown -R rails:rails /rails/db /rails/log /rails/storage /rails/tmp && \
    chmod -R 775 /rails/tmp && \
    chmod -R 755 /rails/log
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
