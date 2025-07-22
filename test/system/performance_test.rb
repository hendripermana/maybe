# frozen_string_literal: true

require "application_system_test_case"
require "performance/performance_test_helper"

class PerformanceTest < ApplicationSystemTestCase
  include PerformanceTestHelper
  
  setup do
    @user = users(:default)
    login_as(@user)
  end
  
  test "measures page load times" do
    pages = {
      dashboard: "/",
      transactions: "/transactions",
      budgets: "/budgets",
      settings: "/settings"
    }
    
    results = {}
    
    pages.each do |name, path|
      results[name] = measure_page_load(path)
    end
    
    # Log results
    Rails.logger.info "Page Load Performance Results:"
    results.each do |page, time|
      Rails.logger.info "  #{page}: #{time.round(2)}ms"
    end
    
    # Assert reasonable load times (adjust thresholds as needed)
    results.each do |page, time|
      assert time < 5000, "#{page} page load time (#{time.round(2)}ms) exceeds threshold"
    end
  end
  
  test "measures theme switching performance" do
    visit "/"
    
    # Measure initial theme switch
    switch_time = measure_theme_switch
    assert switch_time < 300, "Theme switch time (#{switch_time.round(2)}ms) exceeds threshold"
    
    # Switch back and measure again
    switch_time = measure_theme_switch
    assert switch_time < 300, "Theme switch time (#{switch_time.round(2)}ms) exceeds threshold"
  end
  
  test "detects layout shifts during component loading" do
    visit "/"
    
    # Monitor key elements for layout shifts
    monitor_elements_for_shifts([
      ".dashboard-card",
      ".chart-container",
      ".transaction-list",
      ".budget-progress"
    ])
    
    # Trigger component loading (e.g., by clicking a tab or loading more data)
    if has_selector?("[data-controller='tabs']")
      all("[data-controller='tabs'] [role='tab']").last.click
    end
    
    # Check for layout shifts
    shifts = detect_layout_shifts
    
    # Log any detected shifts
    if shifts.any?
      Rails.logger.warn "Layout shifts detected:"
      shifts.each do |shift|
        Rails.logger.warn "  #{shift[:element]}: top #{shift[:top_shift]}px, left #{shift[:left_shift]}px"
      end
    end
    
    # Assert no significant layout shifts
    assert shifts.empty? || shifts.all? { |s| s[:top_shift].abs < 5 && s[:left_shift].abs < 5 },
           "Significant layout shifts detected"
  end
end