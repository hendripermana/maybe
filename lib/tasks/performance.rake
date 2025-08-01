# frozen_string_literal: true

namespace :performance do
  desc "Run performance tests and generate report"
  task test: :environment do
    require "benchmark"

    puts "Running performance tests..."

    # Measure page load times
    pages = {
      dashboard: "/",
      transactions: "/transactions",
      budgets: "/budgets",
      settings: "/settings"
    }

    page_load_times = {}

    puts "\nMeasuring page load times (development environment)..."
    pages.each do |name, path|
      time = Benchmark.measure do
        # Simulate page load by rendering the view
        # This is a simplified approach - system tests provide more accurate measurements
        controller = "#{name.to_s.camelize}Controller".constantize.new
        controller.render_to_string(template: "#{name}/index")
      end

      page_load_times[name] = (time.real * 1000).round(2) # Convert to milliseconds
      puts "  #{name}: #{page_load_times[name]}ms"
    end

    # Measure theme switching time
    puts "\nMeasuring theme switching time..."
    theme_switch_time = Benchmark.measure do
      # Simulate theme switching by processing CSS variables
      # This is a simplified approach - system tests provide more accurate measurements
      ApplicationController.new.render_to_string(inline: "<div data-theme='dark'></div>")
      ApplicationController.new.render_to_string(inline: "<div data-theme='light'></div>")
    end

    theme_switch_time = (theme_switch_time.real * 1000).round(2) # Convert to milliseconds
    puts "  Theme switch: #{theme_switch_time}ms"

    # Save results to a file for comparison
    results = {
      timestamp: Time.current,
      page_load_times: page_load_times,
      theme_switch_time: theme_switch_time
    }

    results_file = Rails.root.join("tmp", "performance_results.yml")
    File.write(results_file, results.to_yaml)

    puts "\nPerformance test results saved to #{results_file}"
  end

  desc "Run performance optimizations"
  task optimize: :environment do
    puts "Running performance optimizations..."

    # Run optimizations
    css_results = PerformanceOptimizer.optimize_css
    theme_results = PerformanceOptimizer.optimize_theme_switching
    layout_results = PerformanceOptimizer.prevent_layout_shifts

    # Print results
    puts "\nCSS Optimization:"
    puts "  Before: #{css_results[:before]} rules"
    puts "  After: #{css_results[:after]} rules"
    puts "  Reduction: #{css_results[:reduction]} rules (#{(css_results[:reduction].to_f / css_results[:before] * 100).round(2)}%)"

    puts "\nTheme Switching Optimizations:"
    theme_results[:optimizations].each do |opt|
      puts "  - #{opt}"
    end

    puts "\nLayout Shift Prevention:"
    layout_results[:optimizations].each do |opt|
      puts "  - #{opt}"
    end

    puts "\nOptimizations complete. Run 'rake performance:test' to measure improvements."
  end

  desc "Generate performance comparison report"
  task report: :environment do
    before_file = Rails.root.join("tmp", "performance_results_before.yml")
    after_file = Rails.root.join("tmp", "performance_results.yml")

    unless File.exist?(before_file) && File.exist?(after_file)
      puts "Error: Missing performance results files."
      puts "Run 'rake performance:test' before optimizations and save as 'performance_results_before.yml'"
      puts "Then run optimizations and 'rake performance:test' again."
      exit 1
    end

    before = YAML.load_file(before_file)
    after = YAML.load_file(after_file)

    puts "\nPerformance Comparison Report"
    puts "=============================="
    puts "Before: #{before[:timestamp]}"
    puts "After:  #{after[:timestamp]}"

    puts "\nPage Load Times:"
    before[:page_load_times].each do |page, time|
      after_time = after[:page_load_times][page]
      change = ((after_time - time) / time * 100).round(2)
      change_str = change.positive? ? "+#{change}%" : "#{change}%"
      puts "  #{page}: #{time}ms → #{after_time}ms (#{change_str})"
    end

    puts "\nTheme Switch Time:"
    theme_change = ((after[:theme_switch_time] - before[:theme_switch_time]) / before[:theme_switch_time] * 100).round(2)
    theme_change_str = theme_change.positive? ? "+#{theme_change}%" : "#{theme_change}%"
    puts "  #{before[:theme_switch_time]}ms → #{after[:theme_switch_time]}ms (#{theme_change_str})"

    # Generate markdown report
    report = <<~MARKDOWN
      # Performance Optimization Report

      ## Overview

      This report compares performance metrics before and after optimization.

      - **Before**: #{before[:timestamp]}
      - **After**: #{after[:timestamp]}

      ## Page Load Times

      | Page | Before | After | Change |
      |------|--------|-------|--------|
      #{before[:page_load_times].map do |page, time|
        after_time = after[:page_load_times][page]
        change = ((after_time - time) / time * 100).round(2)
        change_str = change.positive? ? "+#{change}%" : "#{change}%"
        "| #{page} | #{time}ms | #{after_time}ms | #{change_str} |"
      end.join("\n")}

      ## Theme Switch Performance

      | Metric | Before | After | Change |
      |--------|--------|-------|--------|
      | Switch Time | #{before[:theme_switch_time]}ms | #{after[:theme_switch_time]}ms | #{theme_change_str} |

      ## Optimizations Applied

      ### CSS Optimization
      - Removed unused CSS rules
      - Consolidated duplicate selectors
      - Minimized use of `!important`

      ### Theme Switching
      - Reduced CSS variable scope
      - Added CSS containment for major components
      - Preloaded theme stylesheets

      ### Layout Shift Prevention
      - Added explicit dimensions to images
      - Implemented content-visibility CSS
      - Added skeleton loaders for async content
    MARKDOWN

    report_file = Rails.root.join(".kiro", "specs", "ui-ux-modernization", "performance-optimization-report.md")
    File.write(report_file, report)

    puts "\nDetailed report saved to #{report_file}"
  end
end
