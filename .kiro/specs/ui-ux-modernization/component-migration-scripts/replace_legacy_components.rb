#!/usr/bin/env ruby
# This script helps with automated replacement of simple component usages

require_relative "../../../config/environment"

# Define replacement patterns for common component usages
REPLACEMENTS = {
  # Button Component Replacements
  /render\s+ButtonComponent\.new\(class:\s*["']btn-primary["'](.*?)\)/ => 'render Ui::ButtonComponent.new(variant: :primary\1)',
  /render\s+ButtonComponent\.new\(class:\s*["']btn-secondary["'](.*?)\)/ => 'render Ui::ButtonComponent.new(variant: :secondary\1)',
  /render\s+ButtonComponent\.new\(class:\s*["']btn-destructive["'](.*?)\)/ => 'render Ui::ButtonComponent.new(variant: :destructive\1)',
  /render\s+ButtonComponent\.new\(class:\s*["']btn-outline["'](.*?)\)/ => 'render Ui::ButtonComponent.new(variant: :outline\1)',
  /render\s+ButtonComponent\.new\(class:\s*["']btn-ghost["'](.*?)\)/ => 'render Ui::ButtonComponent.new(variant: :ghost\1)',
  /render\s+ButtonComponent\.new\(class:\s*["']btn-link["'](.*?)\)/ => 'render Ui::ButtonComponent.new(variant: :link\1)',
  
  # Alert Component Replacements
  /render\s+AlertComponent\.new\(message:\s*(.*?),\s*variant:\s*:success(.*?)\)/ => 'render Ui::AlertComponent.new(variant: :success\2) { \1 }',
  /render\s+AlertComponent\.new\(message:\s*(.*?),\s*variant:\s*:error(.*?)\)/ => 'render Ui::AlertComponent.new(variant: :destructive\2) { \1 }',
  /render\s+AlertComponent\.new\(message:\s*(.*?),\s*variant:\s*:info(.*?)\)/ => 'render Ui::AlertComponent.new(variant: :info\2) { \1 }',
  /render\s+AlertComponent\.new\(message:\s*(.*?),\s*variant:\s*:warning(.*?)\)/ => 'render Ui::AlertComponent.new(variant: :warning\2) { \1 }',
  
  # Dialog Component Replacements
  /render\s+DialogComponent\.new\(id:\s*(.*?),\s*title:\s*(.*?)(.*?)\)/ => 'render Ui::ModalComponent.new(id: \1, title: \2, data: { controller: "ui--modal" }\3)',
  
  # Link Component Replacements
  /render\s+LinkComponent\.new\(href:\s*(.*?)(.*?)\)/ => 'render Ui::ButtonComponent.new(variant: :link, href: \1\2)',
  
  # Toggle Component Replacements
  /render\s+ToggleComponent\.new\((.*?)\)/ => 'render Ui::ToggleSwitchComponent.new(\1)',
  
  # Menu Component Replacements
  /render\s+MenuComponent\.new\((.*?)\)/ => 'render Ui::DropdownMenuComponent.new(\1)',
  /render\s+MenuItemComponent\.new\((.*?)\)/ => 'render Ui::DropdownMenuItemComponent.new(\1)',
  
  # Transaction Item Component Replacements
  /render\s+TransactionItemComponent\.new\((.*?)\)/ => 'render Ui::ResponsiveTransactionItemComponent.new(\1)',
  /render\s+TransactionItemSkeletonComponent\.new\((.*?)\)/ => 'render Ui::ResponsiveTransactionItemSkeletonComponent.new(\1)',
  
  # Skeleton Component Replacements
  /render\s+SkeletonComponent\.new\((.*?)\)/ => 'render Ui::SkeletonComponent.new(\1)',
  
  # CSS Class Replacements (Theme Variables)
  /bg-white/ => 'bg-background',
  /text-black/ => 'text-foreground',
  /bg-gray-100/ => 'bg-muted',
  /text-gray-500/ => 'text-muted-foreground',
  /bg-blue-600/ => 'bg-primary',
  /text-blue-600/ => 'text-primary',
  /bg-red-600/ => 'bg-destructive',
  /text-red-600/ => 'text-destructive'
}

def replace_in_file(file, replacements)
  content = File.read(file)
  original_content = content.dup
  changes = 0
  
  replacements.each do |pattern, replacement|
    matches = content.scan(pattern).count
    if matches > 0
      content.gsub!(pattern, replacement)
      changes += matches
    end
  end
  
  if content != original_content
    File.write(file, content)
    puts "Updated #{file} (#{changes} replacements)"
    return changes
  end
  
  return 0
end

puts "=== Legacy Component Replacement Tool ==="
puts "This script will automatically replace legacy component usages with their modern equivalents."
puts "WARNING: Always review changes and run tests after using this tool."
puts "It's recommended to commit your changes before running this script."
puts "\n"

puts "Select replacement mode:"
puts "1. Replace in a specific file"
puts "2. Replace in all view files"
puts "3. Replace in all component files"
puts "4. Replace in all files (views and components)"
puts "5. Dry run (show what would be replaced without making changes)"

print "Enter your choice (1-5): "
choice = STDIN.gets.chomp.to_i

case choice
when 1
  print "Enter file path: "
  file_path = STDIN.gets.chomp
  if File.exist?(file_path)
    changes = replace_in_file(file_path, REPLACEMENTS)
    puts "Completed with #{changes} replacements."
  else
    puts "File not found: #{file_path}"
  end
when 2
  total_changes = 0
  Dir.glob("app/views/**/*.erb").each do |file|
    changes = replace_in_file(file, REPLACEMENTS)
    total_changes += changes
  end
  puts "Completed with #{total_changes} replacements across all view files."
when 3
  total_changes = 0
  Dir.glob("app/components/**/*.erb").each do |file|
    changes = replace_in_file(file, REPLACEMENTS)
    total_changes += changes
  end
  puts "Completed with #{total_changes} replacements across all component files."
when 4
  total_changes = 0
  Dir.glob(["app/views/**/*.erb", "app/components/**/*.erb"]).each do |file|
    changes = replace_in_file(file, REPLACEMENTS)
    total_changes += changes
  end
  puts "Completed with #{total_changes} replacements across all files."
when 5
  puts "=== Dry Run Mode ==="
  total_matches = 0
  
  Dir.glob(["app/views/**/*.erb", "app/components/**/*.erb"]).each do |file|
    content = File.read(file)
    file_matches = 0
    
    REPLACEMENTS.each do |pattern, replacement|
      matches = content.scan(pattern).count
      if matches > 0
        file_matches += matches
        puts "#{file}: #{matches} matches for pattern #{pattern.inspect}"
      end
    end
    
    if file_matches > 0
      puts "Total in #{file}: #{file_matches} matches"
      total_matches += file_matches
    end
  end
  
  puts "=== Dry Run Summary ==="
  puts "Total matches across all files: #{total_matches}"
else
  puts "Invalid choice. Exiting."
end

puts "\nRemember to review all changes and run tests after migration."
puts "For detailed migration guidance, refer to the component migration guide:"
puts ".kiro/specs/ui-ux-modernization/component-migration-guide.md"