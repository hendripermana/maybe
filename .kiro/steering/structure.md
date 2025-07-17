# Project Structure

## Rails Application Layout

### Core Application (`app/`)
- **`controllers/`** - Request handling with concern-based organization
  - Includes API controllers under `api/v1/` namespace
  - Concerns in `controllers/concerns/` for shared functionality
- **`models/`** - ActiveRecord models and business logic
  - Polymorphic associations for accountable types (Depository, Investment, etc.)
  - Concerns in `models/concerns/` for shared model behavior
- **`views/`** - ERB templates organized by controller
- **`components/`** - ViewComponent classes and templates
  - Component-based UI architecture with `.rb` and `.html.erb` files
  - Stimulus controllers for interactive behavior (`.js` files)
- **`jobs/`** - Sidekiq background job classes
- **`mailers/`** - ActionMailer classes for email functionality
- **`helpers/`** - View helper modules
- **`javascript/`** - Stimulus controllers and JavaScript modules
- **`assets/`** - Static assets (images, fonts, stylesheets)

### Configuration (`config/`)
- **`routes.rb`** - Application routing with nested resources and namespaces
- **`application.rb`** - Main application configuration
- **`environments/`** - Environment-specific configurations
- **`initializers/`** - Gem and service configurations
- **`locales/`** - Internationalization files

### Database (`db/`)
- **`migrate/`** - Database migration files with timestamp prefixes
- **`seeds/`** - Database seed data
- **`schema.rb`** - Current database schema

### Testing (`test/`)
- **`models/`**, **`controllers/`**, **`components/`** - Unit tests
- **`system/`** - Integration/system tests with Capybara
- **`fixtures/`** - Test data fixtures
- **`support/`** - Test helper modules
- **`vcr_cassettes/`** - Recorded HTTP interactions for testing

## Key Architectural Patterns

### Polymorphic Account System
- `Account` model with polymorphic `accountable` association
- Account types: Depository, Investment, CreditCard, Loan, Property, Vehicle, Crypto, OtherAsset, OtherLiability
- Each accountable type has specific attributes and behavior

### Entry-based Transaction System
- `Entry` model as base for all financial entries
- Polymorphic `entryable` association for Transaction, Valuation, Trade
- Supports complex financial operations and transfer matching

### Component-driven UI
- ViewComponent architecture for reusable UI elements
- Stimulus controllers for JavaScript behavior
- TailwindCSS with custom design system tokens

### Background Processing
- Sidekiq jobs for data imports, syncing, and heavy operations
- Scheduled jobs for periodic tasks (market data updates, etc.)

## File Naming Conventions

### Models
- Singular names: `account.rb`, `transaction.rb`
- Polymorphic types: `account/depository.rb` (namespaced)
- Concerns: `concerns/syncable.rb`

### Controllers
- Plural names: `accounts_controller.rb`
- Nested resources: `transactions/bulk_updates_controller.rb`
- API namespace: `api/v1/accounts_controller.rb`

### Components
- Component class: `button_component.rb`
- Component template: `button_component.html.erb`
- Component controller: `button_controller.js` (if needed)

### Tests
- Mirror application structure: `test/models/account_test.rb`
- System tests: `test/system/accounts_test.rb`

## Import Conventions

### Ruby Files
- Use explicit requires for non-Rails dependencies
- Leverage Rails autoloading for application classes
- Include concerns with `include ModuleName`

### Component Organization
- Group related components in subdirectories
- Use inheritance for shared component behavior
- Stimulus controllers follow `[name]_controller.js` pattern

### Database Migrations
- Descriptive names with action: `add_currency_to_accounts.rb`
- Use reversible migrations when possible
- Include indexes for foreign keys and frequently queried columns