#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "time"

# Create reports directory
reports_dir = "test/reports"
FileUtils.mkdir_p(reports_dir)

# Generate timestamp for report
timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
report_file = "#{reports_dir}/integration_test_report_#{timestamp}.txt"

# Define test files to run
test_files = [
  "test/system/modernized_pages_user_flows_test.rb",
  "test/system/modernized_pages_accessibility_test.rb",
  "test/system/modernized_pages_cross_browser_test.rb",
  "test/system/modernized_pages_validation_test.rb",
  "test/system/modernized_pages_media_queries_test.rb",
  "test/system/modernized_pages_responsive_test.rb",
  "test/system/navigation_test.rb",
  "test/system/modernized_pages_integration_test.rb",
  "test/system/modernized_pages_bug_tracker.rb"
]

# Run tests and collect results
puts "Running integration tests..."
puts "Results will be saved to #{report_file}"

File.open(report_file, "w") do |f|
  f.puts "# UI/UX Modernization Integration Test Report"
  f.puts "Generated: #{Time.now}"
  f.puts "\n## Test Summary\n"

  total_tests = 0
  passed_tests = 0
  failed_tests = 0

  test_files.each do |test_file|
    f.puts "\n### #{File.basename(test_file, '.rb').gsub('_', ' ').capitalize}\n"

    # Run the test and capture output
    output = `bundle exec ruby -I test #{test_file} 2>&1`

    # Parse test results
    test_count = output.scan(/(\d+) tests, (\d+) assertions/).first
    if test_count
      file_total = test_count[0].to_i
      total_tests += file_total

      failures = output.scan(/(\d+) failures, (\d+) errors/).first
      file_failures = failures ? failures[0].to_i + failures[1].to_i : 0
      failed_tests += file_failures

      file_passed = file_total - file_failures
      passed_tests += file_passed

      f.puts "- Tests: #{file_total}"
      f.puts "- Passed: #{file_passed}"
      f.puts "- Failed: #{file_failures}"
    else
      f.puts "- Error running tests"
    end

    # Extract and save detailed test results
    f.puts "\n#### Detailed Results\n"

    # Extract test names and results
    test_results = output.scan(/test_[^\s]+\s+\[([\d\.]+)s\]\s+([\.EF])/)

    if test_results.any?
      test_results.each do |result|
        test_name = result[0]
        status = case result[1]
        when "."
          "✅ PASS"
        when "E", "F"
          "❌ FAIL"
        else
          "⚠️ UNKNOWN"
        end

        f.puts "- #{status} #{test_name.gsub('test_', '').gsub('_', ' ')}"
      end
    else
      f.puts "- No detailed results available"
    end

    # Extract any error messages
    error_sections = output.scan(/\d+\) Error:\n([^\n]+):\n(.*?)(?=\n\d+\) |\n$)/m)

    if error_sections.any?
      f.puts "\n#### Errors\n"

      error_sections.each do |section|
        test_name = section[0]
        error_message = section[1].strip

        f.puts "**#{test_name}**"
        f.puts "```"
        f.puts error_message
        f.puts "```"
      end
    end
  end

  # Write summary
  f.puts "\n## Overall Summary\n"
  f.puts "- Total Tests: #{total_tests}"
  f.puts "- Passed: #{passed_tests}"
  f.puts "- Failed: #{failed_tests}"
  f.puts "- Success Rate: #{total_tests > 0 ? (passed_tests.to_f / total_tests * 100).round(2) : 0}%"

  # Add recommendations section
  f.puts "\n## Recommendations\n"

  if failed_tests > 0
    f.puts "1. Fix failing tests by running the bug fixer script: `bundle exec ruby -I test test/system/modernized_pages_bug_fixer.rb`"
    f.puts "2. Re-run the integration tests to verify fixes: `bundle exec ruby test/system/run_integration_tests.rb`"
    f.puts "3. Address any remaining issues manually"
  else
    f.puts "All tests passed! The UI/UX modernization is complete and ready for production."
  end
end

puts "Integration test report generated: #{report_file}"
