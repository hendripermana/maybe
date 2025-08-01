# frozen_string_literal: true

# Master component testing suite that combines all component testing helpers
# This file should be required in test_helper.rb

require_relative "component_test_case"
require_relative "theme_test_helper"
require_relative "accessibility_test_helper"
require_relative "visual_regression_helper"
require_relative "component_testing_suite_helper"
require_relative "component_visual_regression_helper"
require_relative "component_accessibility_helper"
require_relative "component_interaction_helper"
require_relative "comprehensive_component_test_case"

module MasterComponentTestingSuite
  # Include all component testing helpers
  include ThemeTestHelper
  include AccessibilityTestHelper
  include VisualRegressionHelper
  include ComponentTestingSuiteHelper
  include ComponentVisualRegressionHelper
  include ComponentAccessibilityHelper
  include ComponentInteractionHelper

  # Master method to generate all tests for a component
  def self.generate_all_tests_for(component_class, options = {})
    # Generate standard tests
    ComprehensiveComponentTestCase.generate_standard_tests_for(component_class, options)

    # Generate visual regression tests
    if options[:visual_regression]
      variants = options[:variants] || [ :default ]
      ComponentVisualRegressionHelper.visual_regression_test_for(component_class, variants)
    end

    # Generate accessibility tests
    if options[:accessibility]
      ComponentAccessibilityHelper.accessibility_test_for(component_class, options)
    end

    # Generate interaction tests
    if options[:interactive] && options[:interactions].present?
      ComponentInteractionHelper.interaction_test_for(component_class, options[:interactions], options)
    end
  end

  # Helper method to run all tests for a component
  def run_all_tests_for(component_class, options = {})
    # Run standard tests
    test_component_comprehensively(
      component_class.new(**options[:props].to_h),
      content: options[:content],
      interactions: options[:interactive] ? (options[:interactions] || [ :click, :hover, :focus ]) : []
    )

    # Run visual regression tests if applicable
    if options[:visual_regression] && respond_to?(:take_component_screenshot)
      component_name = component_class.name.demodulize.underscore.sub(/_component$/, "")
      variant = options[:variant] || "default"

      ThemeTestHelper::THEMES.each do |theme|
        take_component_screenshot(component_name, variant: variant, theme: theme)
      end
    end
  end
end
