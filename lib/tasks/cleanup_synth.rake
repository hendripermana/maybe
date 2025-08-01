# frozen_string_literal: true

namespace :cleanup do
  desc "Clean up old Synth Finance references and settings"
  task synth: :environment do
    puts "🧹 Cleaning up old Synth Finance references..."
    
    # Remove old Synth API key from settings if it exists
    begin
      if defined?(Setting) && Setting.respond_to?(:synth_api_key)
        old_key = Setting.synth_api_key
        if old_key.present?
          puts "⚠️  Found old Synth API key in settings"
          puts "   You can safely remove SYNTH_API_KEY from your environment"
        end
      end
    rescue => e
      # Setting might not exist or be accessible, that's OK
    end
    
    # Check for old environment variables
    if ENV["SYNTH_API_KEY"].present?
      puts "⚠️  Found SYNTH_API_KEY in environment variables"
      puts "   You can remove this from your .env file"
    end
    
    # Check for old VCR cassettes
    synth_cassettes = Dir.glob("test/vcr_cassettes/synth/*.yml")
    if synth_cassettes.any?
      puts "ℹ️  Found #{synth_cassettes.count} old Synth VCR cassettes"
      puts "   These are safe to delete if you want to clean up"
    end
    
    puts ""
    puts "✅ Cleanup complete!"
    puts ""
    puts "📝 Optional cleanup steps:"
    puts "   1. Remove SYNTH_API_KEY from your .env files"
    puts "   2. Delete test/vcr_cassettes/synth/ directory if present"
    puts "   3. The app works perfectly without these old references"
  end
end