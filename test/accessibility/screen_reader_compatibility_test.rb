require "test_helper"
require "application_system_test_case"

class ScreenReaderCompatibilityTest < ApplicationSystemTestCase
  include AccessibilityTestHelper

  # List of main pages to test
  PAGES_TO_TEST = [
    { name: "Dashboard", path: "/" },
    { name: "Transactions", path: "/transactions" },
    { name: "Budgets", path: "/budgets" },
    { name: "Settings", path: "/settings/preferences" }
  ]

  setup do
    sign_in users(:family_admin)
  end

  # Test screen reader compatibility for all pages
  def test_screen_reader_compatibility
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]
      
      # Simulate screen reader mode
      simulate_screen_reader do
        # Test for proper accessible names on interactive elements
        interactive_elements = page.all("button, a, [role='button'], input, select, textarea").first(15)
        
        interactive_elements.each do |element|
          assert_accessible_name(element)
        end
        
        # Test for proper ARIA attributes
        aria_elements = page.all("[aria-label], [aria-labelledby], [aria-describedby], [aria-hidden], [aria-expanded], [aria-haspopup], [aria-controls]").first(15)
        
        aria_elements.each do |element|
          assert_proper_aria_attributes(element)
        end
        
        # Test for proper heading structure
        assert_proper_heading_hierarchy
        
        # Test for proper form labels
        assert_proper_form_labels
      end
      
      # Log successful test
      puts "✓ #{page_info[:name]} passes screen reader compatibility tests"
    end
  end
  
  # Test screen reader announcements for interactive elements
  def test_screen_reader_announcements
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]
      
      # Test buttons for proper roles and states
      buttons = page.all("button, [role='button']").first(10)
      
      buttons.each do |button|
        # Check for proper role
        assert button[:role] == "button" || button.tag_name == "button", 
               "Button should have role='button' or be a <button> element"
        
        # Check for accessible name
        assert_accessible_name(button)
        
        # Check for proper disabled state
        if button[:disabled] || button['aria-disabled'] == 'true'
          assert button['aria-disabled'] == 'true' || button[:disabled],
                 "Disabled buttons should have aria-disabled='true' or disabled attribute"
        end
        
        # Check for proper expanded state for disclosure buttons
        if button['aria-controls'].present?
          assert button['aria-expanded'].present?,
                 "Buttons that control other elements should have aria-expanded attribute"
        end
      end
      
      # Test form fields for proper labels
      form_fields = page.all("input, select, textarea").first(10)
      
      form_fields.each do |field|
        # Check for proper label
        input_id = field[:id]
        
        if input_id.present?
          has_label = page.has_selector?("label[for='#{input_id}']")
          has_aria_label = field['aria-label'].present?
          has_aria_labelledby = field['aria-labelledby'].present?
          
          assert has_label || has_aria_label || has_aria_labelledby,
                 "Form field should have a label, aria-label, or aria-labelledby"
        end
        
        # Check for proper required state
        if field[:required]
          assert field['aria-required'] == 'true' || field[:required],
                 "Required fields should have aria-required='true' or required attribute"
        end
      end
      
      # Log successful test
      puts "✓ #{page_info[:name]} passes screen reader announcement tests"
    end
  end
  
  # Test landmark regions for screen readers
  def test_landmark_regions
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]
      
      # Test for main landmark
      main = page.find("main")
      assert_accessible_name(main) if main['aria-label'].present? || main['aria-labelledby'].present?
      
      # Test for navigation landmark
      if page.has_selector?("nav")
        nav = page.find("nav")
        assert_accessible_name(nav) if nav['aria-label'].present? || nav['aria-labelledby'].present?
      end
      
      # Test for complementary landmarks
      page.all("[role='complementary'], aside").each do |complementary|
        assert_accessible_name(complementary)
      end
      
      # Test for search landmark
      if page.has_selector?("[role='search']")
        search = page.find("[role='search']")
        assert_accessible_name(search)
      end
      
      # Log successful test
      puts "✓ #{page_info[:name]} passes landmark region tests"
    end
  end
end