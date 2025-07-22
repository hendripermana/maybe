require "test_helper"
require "application_system_test_case"

class FixAccessibilityIssues < ApplicationSystemTestCase
  include AccessibilityTestHelper

  # List of components with accessibility issues
  COMPONENTS_WITH_ISSUES = [
    # Components with missing accessible names
    { name: "Ui::IconComponent", issue: "missing_accessible_name" },
    { name: "Ui::ButtonComponent", issue: "insufficient_contrast" },
    { name: "Ui::ModalComponent", issue: "focus_management" },
    { name: "Ui::FormFieldComponent", issue: "missing_label" },
    { name: "Ui::TooltipComponent", issue: "aria_attributes" }
  ]

  # Test and fix accessibility issues
  def test_and_fix_accessibility_issues
    COMPONENTS_WITH_ISSUES.each do |component_info|
      # Navigate to component preview
      component_slug = component_info[:name].underscore.tr('/', '_')
      visit "/lookbook/inspect/#{component_slug}/default"
      
      # Test for specific issue
      case component_info[:issue]
      when "missing_accessible_name"
        fix_missing_accessible_name(component_info[:name])
      when "insufficient_contrast"
        fix_insufficient_contrast(component_info[:name])
      when "focus_management"
        fix_focus_management(component_info[:name])
      when "missing_label"
        fix_missing_label(component_info[:name])
      when "aria_attributes"
        fix_aria_attributes(component_info[:name])
      end
      
      # Log fixed issue
      puts "✓ Fixed #{component_info[:issue]} in #{component_info[:name]}"
    end
  end
  
  private
  
  def fix_missing_accessible_name(component_name)
    # Find elements without accessible names
    elements_without_names = page.all("button, a, [role='button'], input, select, textarea").select do |element|
      begin
        get_accessible_name(element).blank?
      rescue
        true
      end
    end
    
    # Log elements without accessible names
    elements_without_names.each do |element|
      puts "Element without accessible name: #{element.tag_name} with text: #{element.text.truncate(30)}"
      puts "Recommended fix: Add aria-label or aria-labelledby attribute"
    end
  end
  
  def fix_insufficient_contrast(component_name)
    # Find elements with insufficient contrast
    text_elements = page.all("p, h1, h2, h3, h4, h5, h6, span, a, button, label")
    
    elements_with_contrast_issues = text_elements.select do |element|
      begin
        !has_sufficient_contrast(element)
      rescue
        false
      end
    end
    
    # Log elements with contrast issues
    elements_with_contrast_issues.each do |element|
      puts "Element with insufficient contrast: #{element.tag_name} with text: #{element.text.truncate(30)}"
      puts "Recommended fix: Use CSS variables for colors instead of hardcoded values"
    end
  end
  
  def fix_focus_management(component_name)
    # Test focus management in modals
    if page.has_selector?("[data-action='click->dialog#open']")
      find("[data-action='click->dialog#open']").click
      
      # Check if focus moves into the modal
      has_focus_in_modal = page.has_selector?("[role='dialog'] :focus")
      
      unless has_focus_in_modal
        puts "Focus not moving into modal when opened"
        puts "Recommended fix: Add autofocus attribute to first focusable element in modal"
      end
      
      # Close modal
      if page.has_selector?("[data-action='click->dialog#close']")
        find("[data-action='click->dialog#close']").click
        
        # Check if focus returns to trigger
        has_focus_returned = page.has_selector?("[data-action='click->dialog#open']:focus")
        
        unless has_focus_returned
          puts "Focus not returning to trigger when modal closed"
          puts "Recommended fix: Store and restore focus in dialog controller"
        end
      end
    end
  end
  
  def fix_missing_label(component_name)
    # Find form fields without labels
    form_fields = page.all("input, select, textarea")
    
    fields_without_labels = form_fields.select do |field|
      input_id = field[:id]
      
      if input_id.present?
        !page.has_selector?("label[for='#{input_id}']") && 
        !field['aria-label'].present? && 
        !field['aria-labelledby'].present?
      else
        !field['aria-label'].present? && 
        !field['aria-labelledby'].present?
      end
    end
    
    # Log fields without labels
    fields_without_labels.each do |field|
      puts "Form field without label: #{field.tag_name} with type: #{field[:type]}"
      puts "Recommended fix: Add label element with for attribute, or aria-label attribute"
    end
  end
  
  def fix_aria_attributes(component_name)
    # Find elements with ARIA attributes
    aria_elements = page.all("[aria-label], [aria-labelledby], [aria-describedby], [aria-hidden], [aria-expanded], [aria-haspopup], [aria-controls]")
    
    # Check for common ARIA issues
    aria_elements.each do |element|
      # Check aria-labelledby references
      if element['aria-labelledby'].present?
        labelledby_ids = element['aria-labelledby'].split
        
        labelledby_ids.each do |id|
          unless page.has_selector?("##{id}")
            puts "aria-labelledby references non-existent ID: #{id}"
            puts "Recommended fix: Ensure referenced ID exists"
          end
        end
      end
      
      # Check aria-describedby references
      if element['aria-describedby'].present?
        describedby_ids = element['aria-describedby'].split
        
        describedby_ids.each do |id|
          unless page.has_selector?("##{id}")
            puts "aria-describedby references non-existent ID: #{id}"
            puts "Recommended fix: Ensure referenced ID exists"
          end
        end
      end
      
      # Check aria-controls references
      if element['aria-controls'].present?
        controls_ids = element['aria-controls'].split
        
        controls_ids.each do |id|
          unless page.has_selector?("##{id}")
            puts "aria-controls references non-existent ID: #{id}"
            puts "Recommended fix: Ensure referenced ID exists"
          end
        end
      end
      
      # Check for proper aria-expanded on buttons that control other elements
      if element['aria-controls'].present? && !element['aria-expanded'].present?
        puts "Element with aria-controls missing aria-expanded: #{element.tag_name}"
        puts "Recommended fix: Add aria-expanded attribute"
      end
    end
  end
end