# frozen_string_literal: true

namespace :app do
  desc "Verify the app is working correctly after Synth migration"
  task verify: :environment do
    puts "🔍 Verifying Maybe app functionality..."
    
    errors = []
    
    # Test 1: Rails loads
    begin
      puts "✅ Rails application loads successfully"
    rescue => e
      errors << "❌ Rails failed to load: #{e.message}"
    end
    
    # Test 2: Database connection
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      puts "✅ Database connection works"
    rescue => e
      errors << "❌ Database connection failed: #{e.message}"
    end
    
    # Test 3: Exchange rate provider
    begin
      provider = ExchangeRate.provider
      puts "✅ Exchange rate provider: #{provider.class.name}"
    rescue => e
      errors << "❌ Exchange rate provider failed: #{e.message}"
    end
    
    # Test 4: Security provider (optional)
    begin
      provider = Security.provider
      if provider
        puts "✅ Security provider: #{provider.class.name}"
      else
        puts "ℹ️  Security provider: Not configured (manual data entry mode)"
      end
    rescue => e
      errors << "❌ Security provider failed: #{e.message}"
    end
    
    # Test 5: Settings
    begin
      Setting.exchange_rates_api_key
      Setting.alpha_vantage_api_key
      puts "✅ Settings system works"
    rescue => e
      errors << "❌ Settings system failed: #{e.message}"
    end
    
    # Test 6: Basic models
    begin
      User.count
      Family.count
      Account.count
      puts "✅ Core models accessible"
    rescue => e
      errors << "❌ Core models failed: #{e.message}"
    end
    
    puts ""
    
    if errors.empty?
      puts "🎉 All checks passed! Your Maybe app is working correctly."
      puts ""
      puts "📋 Current configuration:"
      puts "   - Exchange rates: #{ExchangeRate.provider.class.name}"
      puts "   - Security data: #{Security.provider&.class&.name || 'Manual entry mode'}"
      puts "   - Database: Connected"
      puts ""
      puts "💡 You can now:"
      puts "   1. Start the server: rails server"
      puts "   2. Create accounts and transactions manually"
      puts "   3. Optionally configure API keys for automatic data fetching"
    else
      puts "❌ Some issues found:"
      errors.each { |error| puts "   #{error}" }
      puts ""
      puts "🔧 Try running: rails db:migrate"
    end
  end
end