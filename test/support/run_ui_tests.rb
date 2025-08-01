#!/usr/bin/env ruby
# frozen_string_literal: true

# UI Testing Runner
# Demonstrates the testing infrastructure capabilities

require_relative "../../config/environment"
require_relative "ui_testing_config"

class UiTestRunner
  def self.run_demo
    puts "🧪 UI Testing Infrastructure Demo"
    puts "=" * 50

    setup_directories
    demonstrate_config
    show_test_matrix
    cleanup_demo
  end

  private

    def self.setup_directories
      puts "\n📁 Setting up test directories..."
      UiTestingConfig.setup_visual_regression_directories
      puts "✅ Visual regression directories created"
    end

    def self.demonstrate_config
      puts "\n⚙️  Testing Configuration:"
      puts "Themes: #{UiTestingConfig::THEME_CONFIG[:themes].join(', ')}"
      puts "Viewports: #{UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports].keys.join(', ')}"
      puts "WCAG Level: #{UiTestingConfig::ACCESSIBILITY_CONFIG[:wcag_level].upcase}"
      puts "CSS Variables: #{UiTestingConfig::THEME_CONFIG[:css_variables].count} defined"
    end

    def self.show_test_matrix
      puts "\n🧮 Component Test Matrix:"

      matrix = UiTestingConfig.component_test_matrix
      puts "Total test combinations: #{matrix.count}"

      # Show first few examples
      matrix.first(5).each do |test_case|
        puts "  - #{test_case[:component]} (#{test_case[:variant]}, #{test_case[:size]}, #{test_case[:state]})"
      end
      puts "  ... and #{matrix.count - 5} more combinations" if matrix.count > 5

      puts "\n🎨 Theme + Viewport Combinations:"
      theme_combos = UiTestingConfig.theme_test_combinations
      theme_combos.each do |combo|
        puts "  - #{combo[:theme]} theme @ #{combo[:viewport]} (#{combo[:dimensions].join('x')})"
      end
    end

    def self.cleanup_demo
      puts "\n🧹 Demo cleanup complete"
      puts "\n📚 Next steps:"
      puts "1. Run component tests: rails test test/components/"
      puts "2. Run system tests: rails test:system"
      puts "3. Check test/support/README.md for detailed usage"
      puts "4. Review example tests in test/system/ui_component_theme_test.rb"
    end
end

# Run demo if called directly
if __FILE__ == $0
  UiTestRunner.run_demo
end
