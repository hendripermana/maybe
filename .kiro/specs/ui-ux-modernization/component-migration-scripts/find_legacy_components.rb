#!/usr/bin/env ruby
# This script helps identify legacy components in your codebase

require_relative "../../../config/environment"

LEGACY_COMPONENTS = [
  "ButtonComponent",
  "AlertComponent",
  "DialogComponent",
  "TabsComponent",
  "TabComponent",
  "MenuComponent",
  "MenuItemComponent",
  "DisclosureComponent",
  "LinkComponent",
  "ToggleComponent",
  "SearchInputComponent",
  "FilterBadgeComponent",
  "FilledIconComponent",
  "SkeletonComponent",
  "TransactionItemComponent",
  "TransactionItemSkeletonComponent"
]

def find_in_views(pattern)
  results = {}
  Dir.glob("app/views/**/*.erb").each do |file|
    content = File.read(file)
    matches = content.scan(pattern)
    results[file] = matches if matches.any?
  end
  results
end

puts "=== Legacy Component Usage Finder ==="
puts "This script will help you identify where legacy components are used in your codebase."
puts "Results will show file paths and the number of occurrences."
puts "\n"

LEGACY_COMPONENTS.each do |component|
  puts "=== Finding usages of #{component} ==="
  pattern = /render\s+#{component}|<%= render\s+#{component}|<%=\s+render\(#{component}/
  results = find_in_views(pattern)
  
  if results.any?
    results.each do |file, matches|
      puts "#{file}: #{matches.count} occurrences"
    end
    total = results.values.flatten.count
    puts "Total: #{total} occurrences"
  else
    puts "No usages found"
  end
  puts "\n"
end

puts "=== Summary ==="
puts "To migrate these components, refer to the component migration guide:"
puts ".kiro/specs/ui-ux-modernization/component-migration-guide.md"