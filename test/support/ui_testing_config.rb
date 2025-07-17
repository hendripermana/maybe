# frozen_string_literal: true

# UI Testing Configuration
# Centralizes configuration for visual regression, theme, and accessibility testing

module UiTestingConfig
  # Visual regression testing configuration
  VISUAL_REGRESSION_CONFIG = {
    screenshot_dir: Rails.root.join("test", "visual_regression", "screenshots"),
    baseline_dir: Rails.root.join("test", "visual_regression", "screenshots", "baseline"),
    threshold: 0.01, # 1% difference threshold
    viewports: {
      mobile: [375, 667],
      tablet: [768, 1024], 
      desktop: [1200, 800],
      large: [1400, 1400]
    }
  }.freeze
  
  # Theme testing configuration
  THEME_CONFIG = {
    themes: %w[light dark],
    css_variables: %w[
      --background --foreground --primary --secondary
      --muted --accent --destructive --card --border
      --input --ring
    ],
    hardcoded_color_patterns: [
      /\bbg-white\b/, /\bbg-black\b/, /\bbg-gray-\d+\b/, /\bbg-slate-\d+\b/,
      /\btext-white\b/, /\btext-black\b/, /\btext-gray-\d+\b/, /\btext-slate-\d+\b/,
      /\bborder-white\b/, /\bborder-black\b/, /\bborder-gray-\d+\b/, /\bborder-slate-\d+\b/
    ]
  }.freeze
  
  # Accessibility testing configuration
  ACCESSIBILITY_CONFIG = {
    wcag_level: :aa, # :aa or :aaa
    color_contrast: {
      normal_text: 4.5,
      large_text: 3.0,
      aaa_normal: 7.0,
      aaa_large: 4.5
    },
    required_attributes: %w[alt aria-label aria-labelledby],
    focus_indicators: %w[outline box-shadow border],
    keyboard_navigable_elements: %w[a button input select textarea [tabindex]]
  }.freeze
  
  # Component testing selectors
  COMPONENT_SELECTORS = {
    buttons: '.btn-modern-primary, .btn-modern-secondary, .btn-modern-ghost, .btn-modern-destructive',
    cards: '.card-modern, .bg-card',
    forms: 'input, select, textarea, button[type="submit"]',
    navigation: 'nav a, [role="navigation"] a',
    interactive: 'button, a, input, select, textarea, [role="button"]'
  }.freeze
  
  # Test data for component variations
  COMPONENT_VARIANTS = {
    button: {
      variants: %i[primary secondary ghost destructive],
      sizes: %i[sm md lg],
      states: %i[default hover focus disabled loading]
    },
    card: {
      variants: %i[default elevated outlined],
      sizes: %i[sm md lg],
      states: %i[default hover]
    },
    input: {
      types: %w[text email password number],
      states: %i[default focus error disabled]
    }
  }.freeze
  
  class << self
    def setup_visual_regression_directories
      FileUtils.mkdir_p(VISUAL_REGRESSION_CONFIG[:screenshot_dir])
      FileUtils.mkdir_p(VISUAL_REGRESSION_CONFIG[:baseline_dir])
    end
    
    def cleanup_old_screenshots(days_old: 7)
      cutoff_date = days_old.days.ago
      screenshot_dir = VISUAL_REGRESSION_CONFIG[:screenshot_dir]
      
      Dir.glob(screenshot_dir.join("*.png")).each do |file|
        File.delete(file) if File.mtime(file) < cutoff_date
      end
    end
    
    def component_test_matrix
      # Generate test combinations for comprehensive component testing
      COMPONENT_VARIANTS.flat_map do |component, config|
        variants = config[:variants] || [:default]
        sizes = config[:sizes] || [:default]
        states = config[:states] || [:default]
        
        variants.product(sizes, states).map do |variant, size, state|
          {
            component: component,
            variant: variant,
            size: size,
            state: state
          }
        end
      end
    end
    
    def theme_test_combinations
      # Generate all theme + viewport combinations for testing
      THEME_CONFIG[:themes].product(VISUAL_REGRESSION_CONFIG[:viewports].keys).map do |theme, viewport|
        {
          theme: theme,
          viewport: viewport,
          dimensions: VISUAL_REGRESSION_CONFIG[:viewports][viewport]
        }
      end
    end
  end
end