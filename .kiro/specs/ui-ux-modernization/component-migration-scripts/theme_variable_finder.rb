#!/usr/bin/env ruby
# This script helps identify hardcoded colors that should be replaced with theme variables

require_relative "../../../config/environment"

# Define patterns for hardcoded colors that should be replaced with theme variables
HARDCODED_COLORS = [
  # Background colors
  /bg-white/,
  /bg-black/,
  /bg-gray-\d+/,
  /bg-blue-\d+/,
  /bg-red-\d+/,
  /bg-green-\d+/,
  /bg-yellow-\d+/,
  /bg-purple-\d+/,
  /bg-pink-\d+/,
  /bg-indigo-\d+/,
  /bg-teal-\d+/,
  /bg-orange-\d+/,
  
  # Text colors
  /text-white/,
  /text-black/,
  /text-gray-\d+/,
  /text-blue-\d+/,
  /text-red-\d+/,
  /text-green-\d+/,
  /text-yellow-\d+/,
  /text-purple-\d+/,
  /text-pink-\d+/,
  /text-indigo-\d+/,
  /text-teal-\d+/,
  /text-orange-\d+/,
  
  # Border colors
  /border-white/,
  /border-black/,
  /border-gray-\d+/,
  /border-blue-\d+/,
  /border-red-\d+/,
  /border-green-\d+/,
  /border-yellow-\d+/,
  /border-purple-\d+/,
  /border-pink-\d+/,
  /border-indigo-\d+/,
  /border-teal-\d+/,
  /border-orange-\d+/,
  
  # Ring colors
  /ring-white/,
  /ring-black/,
  /ring-gray-\d+/,
  /ring-blue-\d+/,
  /ring-red-\d+/,
  /ring-green-\d+/,
  /ring-yellow-\d+/,
  /ring-purple-\d+/,
  /ring-pink-\d+/,
  /ring-indigo-\d+/,
  /ring-teal-\d+/,
  /ring-orange-\d+/,
  
  # Divide colors
  /divide-white/,
  /divide-black/,
  /divide-gray-\d+/,
  /divide-blue-\d+/,
  /divide-red-\d+/,
  /divide-green-\d+/,
  /divide-yellow-\d+/,
  /divide-purple-\d+/,
  /divide-pink-\d+/,
  /divide-indigo-\d+/,
  /divide-teal-\d+/,
  /divide-orange-\d+/,
  
  # Placeholder colors
  /placeholder-white/,
  /placeholder-black/,
  /placeholder-gray-\d+/,
  /placeholder-blue-\d+/,
  /placeholder-red-\d+/,
  /placeholder-green-\d+/,
  /placeholder-yellow-\d+/,
  /placeholder-purple-\d+/,
  /placeholder-pink-\d+/,
  /placeholder-indigo-\d+/,
  /placeholder-teal-\d+/,
  /placeholder-orange-\d+/
]

# Define suggested replacements for common hardcoded colors
COLOR_REPLACEMENTS = {
  "bg-white" => "bg-background",
  "bg-black" => "bg-foreground",
  "bg-gray-50" => "bg-muted",
  "bg-gray-100" => "bg-muted",
  "bg-gray-200" => "bg-muted",
  "bg-gray-800" => "bg-muted-foreground",
  "bg-gray-900" => "bg-muted-foreground",
  "bg-blue-50" => "bg-primary/10",
  "bg-blue-100" => "bg-primary/20",
  "bg-blue-500" => "bg-primary",
  "bg-blue-600" => "bg-primary",
  "bg-blue-700" => "bg-primary",
  "bg-red-50" => "bg-destructive/10",
  "bg-red-100" => "bg-destructive/20",
  "bg-red-500" => "bg-destructive",
  "bg-red-600" => "bg-destructive",
  "bg-red-700" => "bg-destructive",
  "bg-green-50" => "bg-success/10",
  "bg-green-100" => "bg-success/20",
  "bg-green-500" => "bg-success",
  "bg-green-600" => "bg-success",
  "bg-green-700" => "bg-success",
  "bg-yellow-50" => "bg-warning/10",
  "bg-yellow-100" => "bg-warning/20",
  "bg-yellow-500" => "bg-warning",
  "bg-yellow-600" => "bg-warning",
  "bg-yellow-700" => "bg-warning",
  
  "text-white" => "text-background",
  "text-black" => "text-foreground",
  "text-gray-400" => "text-muted-foreground",
  "text-gray-500" => "text-muted-foreground",
  "text-gray-600" => "text-muted-foreground",
  "text-gray-700" => "text-foreground",
  "text-gray-800" => "text-foreground",
  "text-gray-900" => "text-foreground",
  "text-blue-500" => "text-primary",
  "text-blue-600" => "text-primary",
  "text-blue-700" => "text-primary",
  "text-red-500" => "text-destructive",
  "text-red-600" => "text-destructive",
  "text-red-700" => "text-destructive",
  "text-green-500" => "text-success",
  "text-green-600" => "text-success",
  "text-green-700" => "text-success",
  "text-yellow-500" => "text-warning",
  "text-yellow-600" => "text-warning",
  "text-yellow-700" => "text-warning",
  
  "border-gray-100" => "border-border",
  "border-gray-200" => "border-border",
  "border-gray-300" => "border-border",
  "border-blue-500" => "border-primary",
  "border-blue-600" => "border-primary",
  "border-red-500" => "border-destructive",
  "border-red-600" => "border-destructive",
  "border-green-500" => "border-success",
  "border-green-600" => "border-success",
  "border-yellow-500" => "border-warning",
  "border-yellow-600" => "border-warning",
  
  "ring-gray-200" => "ring-border",
  "ring-blue-500" => "ring-primary",
  "ring-blue-600" => "ring-primary",
  "ring-red-500" => "ring-destructive",
  "ring-red-600" => "ring-destructive"
}

def find_hardcoded_colors(file)
  content = File.read(file)
  results = {}
  
  HARDCODED_COLORS.each do |pattern|
    matches = content.scan(pattern)
    matches.each do |match|
      match_str = match.is_a?(Array) ? match[0] : match
      results[match_str] ||= 0
      results[match_str] += 1
    end
  end
  
  results
end

puts "=== Hardcoded Color Finder ==="
puts "This script will help you identify hardcoded colors that should be replaced with theme variables."
puts "\n"

puts "Select search mode:"
puts "1. Search in a specific file"
puts "2. Search in all view files"
puts "3. Search in all component files"
puts "4. Search in all files (views and components)"

print "Enter your choice (1-4): "
choice = STDIN.gets.chomp.to_i

files_to_search = case choice
when 1
  print "Enter file path: "
  file_path = STDIN.gets.chomp
  File.exist?(file_path) ? [file_path] : []
when 2
  Dir.glob("app/views/**/*.erb")
when 3
  Dir.glob("app/components/**/*.{erb,rb}")
when 4
  Dir.glob(["app/views/**/*.erb", "app/components/**/*.{erb,rb}"])
else
  puts "Invalid choice. Exiting."
  exit
end

if files_to_search.empty?
  puts "No files to search. Exiting."
  exit
end

puts "\nSearching #{files_to_search.count} files for hardcoded colors..."

all_results = {}
file_counts = {}

files_to_search.each do |file|
  results = find_hardcoded_colors(file)
  
  if results.any?
    file_counts[file] = results.values.sum
    results.each do |color, count|
      all_results[color] ||= 0
      all_results[color] += count
    end
  end
end

if all_results.any?
  puts "\n=== Results ==="
  puts "Found #{all_results.values.sum} instances of hardcoded colors in #{file_counts.keys.count} files."
  
  puts "\nTop files with hardcoded colors:"
  file_counts.sort_by { |_, count| -count }.first(10).each do |file, count|
    puts "#{file}: #{count} instances"
  end
  
  puts "\nHardcoded colors by frequency:"
  all_results.sort_by { |_, count| -count }.each do |color, count|
    replacement = COLOR_REPLACEMENTS[color]
    replacement_text = replacement ? " (suggested replacement: #{replacement})" : ""
    puts "#{color}: #{count} instances#{replacement_text}"
  end
  
  puts "\n=== Suggested Actions ==="
  puts "1. Replace hardcoded colors with theme variables using the suggested replacements."
  puts "2. Test the application in both light and dark themes after making changes."
  puts "3. Update any custom components to use theme variables instead of hardcoded colors."
  puts "\nFor detailed migration guidance, refer to the component migration guide:"
  puts ".kiro/specs/ui-ux-modernization/component-migration-guide.md"
else
  puts "No hardcoded colors found in the selected files."
end