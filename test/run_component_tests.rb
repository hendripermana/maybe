#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to run all component tests with proper reporting
# Usage: ruby test/run_component_tests.rb

require 'fileutils'

# Define test directories
COMPONENT_TEST_DIR = File.join('test', 'components')
REPORT_DIR = File.join('tmp', 'component_test_reports')

# Create report directory if it doesn't exist
FileUtils.mkdir_p(REPORT_DIR)

# Get all component test files
component_test_files = Dir.glob(File.join(COMPONENT_TEST_DIR, '**', '*_test.rb'))

puts "Found #{component_test_files.length} component test files"

# Run each test file
success_count = 0
failure_count = 0

component_test_files.each do |test_file|
  component_name = File.basename(test_file, '_test.rb')
  report_file = File.join(REPORT_DIR, "#{component_name}_report.txt")
  
  puts "Running tests for #{component_name}..."
  
  # Run the test and capture output
  command = "bundle exec ruby -I test #{test_file} --name=/./ > #{report_file} 2>&1"
  system(command)
  
  # Check if test passed
  if $?.success?
    success_count += 1
    puts "✅ #{component_name} tests passed"
  else
    failure_count += 1
    puts "❌ #{component_name} tests failed. See #{report_file} for details."
  end
end

# Print summary
puts "\n----- Component Test Summary -----"
puts "Total tests: #{component_test_files.length}"
puts "Passed: #{success_count}"
puts "Failed: #{failure_count}"
puts "Success rate: #{(success_count.to_f / component_test_files.length * 100).round(2)}%"
puts "Test reports saved to #{REPORT_DIR}"

# Exit with failure if any tests failed
exit(failure_count > 0 ? 1 : 0)