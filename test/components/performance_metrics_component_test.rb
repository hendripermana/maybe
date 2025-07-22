# frozen_string_literal: true

require "test_helper"

class PerformanceMetricsComponentTest < ViewComponent::TestCase
  test "renders with hidden metrics by default" do
    render_inline(PerformanceMetricsComponent.new)
    
    assert_selector "div.performance-metrics"
    refute_selector "div.performance-metrics__container"
  end
  
  test "renders with visible metrics when show_in_ui is true" do
    render_inline(PerformanceMetricsComponent.new(show_in_ui: true))
    
    assert_selector "div.performance-metrics"
    assert_selector "div.performance-metrics__container"
    assert_selector "h3.performance-metrics__title", text: "Performance Metrics"
    assert_selector "div.performance-metrics__results"
  end
end