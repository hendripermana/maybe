#!/usr/bin/env ruby
# This script runs the cross-browser UI tests in multiple browsers
# and collects the results

require 'fileutils'
require 'json'

# Ensure screenshots directory exists
FileUtils.mkdir_p('tmp/screenshots')
FileUtils.mkdir_p('tmp/cross_browser_results')

# Define browsers to test
browsers = ['chrome', 'firefox', 'safari', 'edge']

# Results storage
results = {
  timestamp: Time.now.iso8601,
  browsers: {}
}

# Run tests for each browser
browsers.each do |browser|
  puts "Running tests in #{browser.capitalize}..."
  
  # Create browser-specific results
  results[:browsers][browser] = {
    passed: 0,
    failed: 0,
    errors: []
  }
  
  # Run the tests
  output = `BROWSER=#{browser} bin/rails test:system test/system/cross_browser_ui_test.rb 2>&1`
  
  # Parse results
  if output.include?('0 failures, 0 errors')
    results[:browsers][browser][:passed] = output.match(/(\d+) runs/)[1].to_i
    puts "✅ All tests passed in #{browser.capitalize}"
  else
    # Count failures and errors
    failures = output.match(/(\d+) failures/)[1].to_i rescue 0
    errors = output.match(/(\d+) errors/)[1].to_i rescue 0
    
    results[:browsers][browser][:failed] = failures + errors
    results[:browsers][browser][:passed] = output.match(/(\d+) runs/)[1].to_i - (failures + errors) rescue 0
    
    # Extract error messages
    error_sections = output.scan(/Error:\n(.*?)\n\n/m)
    error_sections.each do |error|
      results[:browsers][browser][:errors] << error[0].strip
    end
    
    puts "❌ Tests failed in #{browser.capitalize}: #{failures} failures, #{errors} errors"
  end
end

# Save results to JSON file
File.write('tmp/cross_browser_results/results.json', JSON.pretty_generate(results))

# Generate HTML report
html_report = <<~HTML
<!DOCTYPE html>
<html>
<head>
  <title>Cross-Browser Testing Results</title>
  <style>
    body { font-family: system-ui, sans-serif; line-height: 1.5; max-width: 1200px; margin: 0 auto; padding: 20px; }
    h1 { color: #333; }
    .browser { margin-bottom: 30px; border: 1px solid #ddd; border-radius: 5px; padding: 15px; }
    .browser h2 { margin-top: 0; }
    .success { color: green; }
    .failure { color: red; }
    .error { background: #fff0f0; padding: 10px; border-left: 3px solid red; margin: 10px 0; }
    .screenshots { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; margin-top: 20px; }
    .screenshot { border: 1px solid #ddd; padding: 10px; }
    .screenshot img { max-width: 100%; }
  </style>
</head>
<body>
  <h1>Cross-Browser Testing Results</h1>
  <p>Generated on #{Time.now}</p>
  
  <div class="summary">
    <h2>Summary</h2>
    <table border="1" cellpadding="5" cellspacing="0">
      <tr>
        <th>Browser</th>
        <th>Passed</th>
        <th>Failed</th>
        <th>Status</th>
      </tr>
      #{browsers.map { |browser|
        status = results[:browsers][browser][:failed] == 0 ? '<span class="success">PASS</span>' : '<span class="failure">FAIL</span>'
        "<tr>
          <td>#{browser.capitalize}</td>
          <td>#{results[:browsers][browser][:passed]}</td>
          <td>#{results[:browsers][browser][:failed]}</td>
          <td>#{status}</td>
        </tr>"
      }.join("\n      ")}
    </table>
  </div>
  
  #{browsers.map { |browser|
    errors_html = results[:browsers][browser][:errors].map { |error|
      "<div class=\"error\">#{error}</div>"
    }.join("\n      ")
    
    "<div class=\"browser\">
      <h2>#{browser.capitalize}</h2>
      <p>Passed: #{results[:browsers][browser][:passed]}, Failed: #{results[:browsers][browser][:failed]}</p>
      #{errors_html.empty? ? "" : "<h3>Errors</h3>\n      #{errors_html}"}
    </div>"
  }.join("\n  ")}
  
  <h2>Screenshots</h2>
  <div class="screenshots">
    #{Dir.glob('tmp/screenshots/*.png').map { |file|
      browser = file.match(/-(chrome|firefox|safari|edge)-/)[1] rescue "unknown"
      page = file.match(/\/(.*?)-(chrome|firefox|safari|edge)-/)[1] rescue "unknown"
      "<div class=\"screenshot\">
        <h3>#{page} (#{browser.capitalize})</h3>
        <img src=\"#{file.sub('tmp/', '../')}\" alt=\"#{page} in #{browser}\">
      </div>"
    }.join("\n    ")}
  </div>
</body>
</html>
HTML

File.write('tmp/cross_browser_results/report.html', html_report)

puts "Testing complete. Results saved to tmp/cross_browser_results/"
puts "Open tmp/cross_browser_results/report.html to view the report"