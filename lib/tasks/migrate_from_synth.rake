# frozen_string_literal: true

namespace :migrate do
  desc "Migrate from Synth Finance to new providers (ExchangeRatesAPI.io and Alpha Vantage)"
  task from_synth: :environment do
    puts "🔄 Migrating from Synth Finance to new providers..."
    
    # Check if user has Synth API key configured
    synth_key = ENV["SYNTH_API_KEY"] || Setting.synth_api_key rescue nil
    
    if synth_key.present?
      puts "⚠️  Found existing Synth API key. Please note:"
      puts "   - Synth Finance is no longer supported"
      puts "   - You'll need to get new API keys from:"
      puts "     • ExchangeRatesAPI.io (for currency exchange rates)"
      puts "     • Alpha Vantage (for stock prices)"
      puts ""
      puts "📝 To configure new providers:"
      puts "   1. Get free API key from https://exchangeratesapi.io/"
      puts "   2. Get free API key from https://www.alphavantage.co/"
      puts "   3. Set environment variables:"
      puts "      export EXCHANGE_RATES_API_KEY=your_key_here"
      puts "      export ALPHA_VANTAGE_API_KEY=your_key_here"
      puts "   4. Or configure in Settings > Self Hosting (if self-hosted)"
      puts ""
    end
    
    # Clear any cached Synth data that might be stale
    puts "🧹 Clearing potentially stale cached data..."
    
    # Count what we're about to clear
    exchange_rates_count = ExchangeRate.count
    security_prices_count = Security::Price.count
    
    puts "   - #{exchange_rates_count} exchange rates"
    puts "   - #{security_prices_count} security prices"
    
    if exchange_rates_count > 0 || security_prices_count > 0
      print "❓ Clear this cached data? (y/N): "
      response = STDIN.gets.chomp.downcase
      
      if response == 'y' || response == 'yes'
        ExchangeRate.delete_all
        Security::Price.delete_all
        puts "✅ Cached data cleared. New providers will fetch fresh data."
      else
        puts "⏭️  Skipping data clearing. Existing data will be used where available."
      end
    else
      puts "✅ No cached data found to clear."
    end
    
    # Test new providers if configured
    puts ""
    puts "🔍 Testing new provider configurations..."
    
    # Test Exchange Rates API
    exchange_rates_key = ENV["EXCHANGE_RATES_API_KEY"] || Setting.exchange_rates_api_key rescue nil
    if exchange_rates_key.present?
      begin
        provider = Provider::ExchangeRatesApi.new(exchange_rates_key)
        if provider.healthy?.success?
          puts "✅ ExchangeRatesAPI.io: Connected successfully"
        else
          puts "❌ ExchangeRatesAPI.io: Connection failed"
        end
      rescue => e
        puts "❌ ExchangeRatesAPI.io: Error - #{e.message}"
      end
    else
      puts "⚠️  ExchangeRatesAPI.io: No API key configured (free tier available without key)"
    end
    
    # Test Alpha Vantage
    alpha_vantage_key = ENV["ALPHA_VANTAGE_API_KEY"] || Setting.alpha_vantage_api_key rescue nil
    if alpha_vantage_key.present?
      begin
        provider = Provider::AlphaVantage.new(alpha_vantage_key)
        if provider.healthy?.success?
          puts "✅ Alpha Vantage: Connected successfully"
        else
          puts "❌ Alpha Vantage: Connection failed"
        end
      rescue => e
        puts "❌ Alpha Vantage: Error - #{e.message}"
      end
    else
      puts "⚠️  Alpha Vantage: No API key configured (required for stock prices)"
    end
    
    puts ""
    puts "🎉 Migration complete!"
    puts ""
    puts "📋 Next steps:"
    puts "   1. Configure API keys for the new providers"
    puts "   2. Test currency conversion and stock price features"
    puts "   3. Remove old SYNTH_API_KEY environment variable"
    puts ""
    puts "💡 Free tier limits:"
    puts "   - ExchangeRatesAPI.io: 1,000 requests/month"
    puts "   - Alpha Vantage: 25 requests/day"
    puts ""
  end
end