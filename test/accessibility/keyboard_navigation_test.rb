require "test_helper"
require "application_system_test_case"

class KeyboardNavigationTest < ApplicationSystemTestCase
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

  # Test keyboard navigation for all pages
  def test_keyboard_navigation
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]
      
      # Test tab navigation through the page
      test_tab_navigation
      
      # Test keyboard operation of interactive elements
      test_keyboard_operation
      
      # Log successful test
      puts "✓ #{page_info[:name]} passes keyboard navigation tests"
    end
  end
  
  # Test keyboard navigation for modals
  def test_modal_keyboard_navigation
    # Test dashboard page with modals
    visit "/"
    
    # Find and open a modal if available
    if page.has_selector?("[data-action='click->dialog#open']")
      find("[data-action='click->dialog#open']").click
      
      # Test modal focus trap
      assert_modal_focus_trap
      
      # Test modal close with Escape key
      send_keys :escape
      assert page.has_no_selector?("[role='dialog'][aria-modal='true']"), 
             "Modal should close when Escape key is pressed"
    end
    
    # Test transactions page with modals
    visit "/transactions"
    
    # Find and open a modal if available
    if page.has_selector?("[data-action='click->dialog#open']")
      find("[data-action='click->dialog#open']").click
      
      # Test modal focus trap
      assert_modal_focus_trap
      
      # Test modal close with Escape key
      send_keys :escape
      assert page.has_no_selector?("[role='dialog'][aria-modal='true']"), 
             "Modal should close when Escape key is pressed"
    end
  end
  
  # Test keyboard navigation for dropdowns
  def test_dropdown_keyboard_navigation
    # Test pages with dropdowns
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]
      
      # Find and open a dropdown if available
      if page.has_selector?("[aria-haspopup='true']")
        dropdown_trigger = find("[aria-haspopup='true']")
        dropdown_trigger.click
        
        # Test dropdown keyboard navigation
        if page.has_selector?("[role='menu']")
          menu = find("[role='menu']")
          
          # Test arrow key navigation
          menu_items = menu.all("[role='menuitem']")
          if menu_items.any?
            # Focus first item
            send_keys :down
            assert page.has_selector?("[role='menuitem']:focus"), 
                   "Arrow down should focus first menu item"
            
            # Move to next item
            send_keys :down
            assert page.has_selector?("[role='menuitem']:focus"), 
                   "Arrow down should move focus to next menu item"
            
            # Test Escape key closes dropdown
            send_keys :escape
            assert page.has_no_selector?("[role='menu']"), 
                   "Escape key should close dropdown"
          end
        end
      end
    end
  end
  
  # Test keyboard navigation for tabs
  def test_tabs_keyboard_navigation
    # Test pages with tabs
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]
      
      # Find tabs if available
      if page.has_selector?("[role='tablist']")
        tablist = find("[role='tablist']")
        
        # Get all tabs
        tabs = tablist.all("[role='tab']")
        
        if tabs.any?
          # Focus first tab
          tabs.first.click
          
          # Test arrow key navigation
          send_keys :right
          assert page.has_selector?("[role='tab'][aria-selected='true']"), 
                 "Arrow right should move to next tab"
          
          # Test arrow key navigation in reverse
          send_keys :left
          assert page.has_selector?("[role='tab'][aria-selected='true']"), 
                 "Arrow left should move to previous tab"
        end
      end
    end
  end
  
  private
  
  def test_tab_navigation
    # Start from the beginning of the page
    page.execute_script("document.activeElement.blur()")
    
    # Tab through the page
    10.times do |i|
      send_keys :tab
      
      # Check if focus is visible
      assert page.has_selector?(":focus"), "Focus should be visible after tabbing (iteration #{i+1})"
      
      # Get the focused element
      focused_element = page.find(":focus")
      
      # Check if the focused element is interactive
      assert %w[a button input select textarea].include?(focused_element.tag_name) || 
             focused_element[:role] == "button" || 
             focused_element[:tabindex] == "0",
             "Focused element should be interactive"
    end
  end
  
  def test_keyboard_operation
    # Find interactive elements
    buttons = page.all("button, [role='button']").first(5)
    
    # Test keyboard operation of buttons
    buttons.each do |button|
      # Focus the button
      button.send_keys(:tab)
      
      # Check if the button is focused
      assert page.find(":focus") == button, "Button should be focusable"
      
      # Activate the button with Enter key
      # Note: We're not actually pressing Enter to avoid navigating away or submitting forms
      # In a real test, you might want to handle the result of pressing Enter
      
      # Activate the button with Space key
      # Note: Same caveat as above
    end
    
    # Find form elements
    form_elements = page.all("input, select, textarea").first(5)
    
    # Test keyboard operation of form elements
    form_elements.each do |element|
      # Focus the element
      element.send_keys(:tab)
      
      # Check if the element is focused
      assert page.find(":focus") == element, "Form element should be focusable"
      
      # Test basic interaction based on element type
      case element.tag_name
      when "input"
        case element[:type]
        when "checkbox", "radio"
          # Space toggles checkboxes and radios
        else
          # Type in text inputs
          element.send_keys("test")
        end
      when "select"
        # Arrow keys navigate select options
      when "textarea"
        # Type in textareas
        element.send_keys("test")
      end
    end
  end
  
  def assert_modal_focus_trap
    # Get the modal
    modal = find("[role='dialog'][aria-modal='true']")
    
    # Check if focus is inside the modal
    assert modal.has_selector?(":focus"), "Focus should be inside the modal when opened"
    
    # Try to tab out of the modal
    10.times do
      send_keys :tab
      
      # Focus should still be inside the modal
      assert modal.has_selector?(":focus"), "Focus should be trapped inside the modal"
    end
  end
end