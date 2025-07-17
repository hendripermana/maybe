# Technology Stack

## Framework & Language
- **Ruby on Rails 7.2.2** - Main web framework
- **Ruby 3.4.4** - Programming language (see `.ruby-version`)
- **PostgreSQL** - Primary database (>9.3 required)
- **Redis** - Caching and session storage

## Frontend
- **Hotwire** (Turbo + Stimulus) - Modern Rails frontend approach
- **TailwindCSS** - Utility-first CSS framework with custom design system
- **ViewComponent** - Component-based view architecture
- **Lookbook** - Component development and documentation
- **Importmap** - JavaScript module management
- **Propshaft** - Asset pipeline

## Background Processing
- **Sidekiq** - Background job processing
- **Sidekiq-cron** - Scheduled job management

## Testing
- **Minitest** - Test framework
- **Capybara + Selenium** - System/integration testing
- **VCR + WebMock** - HTTP request mocking
- **Mocha** - Mocking and stubbing

## Code Quality & Linting
- **Biome** - JavaScript/TypeScript linting and formatting
- **RuboCop Rails Omakase** - Ruby code style enforcement
- **Brakeman** - Security vulnerability scanning
- **ERB Lint** - ERB template linting

## Monitoring & Performance
- **Sentry** - Error tracking and monitoring
- **Skylight** - Rails performance monitoring
- **Rack Mini Profiler** - Development profiling
- **Yabeda + Prometheus** - Metrics collection

## Development Tools
- **Foreman** - Process management (see `Procfile.dev`)
- **Hotwire Livereload** - Development auto-reload
- **Docker** - Containerization and deployment

## Common Commands

### Development Setup
```bash
# Initial setup
bin/setup
cp .env.local.example .env.local

# Start development server
bin/dev

# Load demo data
rake demo_data:default
```

### Testing
```bash
# Run all tests
rails test

# Run specific test file
rails test test/models/account_test.rb

# Run system tests
rails test:system
```

### Code Quality
```bash
# Ruby linting
bundle exec rubocop

# JavaScript linting and formatting
npm run lint
npm run format

# Security scanning
bundle exec brakeman
```

### Database
```bash
# Run migrations
rails db:migrate

# Reset database
rails db:reset

# Create migration
rails generate migration AddFieldToModel field:type
```

### Background Jobs
```bash
# Start Sidekiq worker
bundle exec sidekiq

# View job queue (in development)
# Visit http://localhost:3000/sidekiq
```