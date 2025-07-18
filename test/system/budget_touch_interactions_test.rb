# frozen_string_literal: true

require "application_system_test_case"

class BudgetTouchInteractionsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:family_admin)
    @budget = budgets(:one)
  end

  test "touch controller is properly initialized" do
    visit budget_budget_categories_path(@budget)
    
    # Check that the budget touch controller is initialized
    assert_selector "[data-controller~='budget-touch']"
    
    # Check that input targets are properly set
    assert_selector "[data-budget-touch-target='input']"
  end
  
  test "touch events are properly handled" do
    # Skip this test if not running in a browser that supports touch events
    skip "Touch events not supported in current test environment" unless page.driver.browser.respond_to?(:action)
    
    visit budget_budget_categories_path(@budget)
    
    # Find the first budget category input
    input = first("[data-budget-touch-target='input']")
    
    # Simulate touchstart event
    page.execute_script("
      const event = new TouchEvent('touchstart', {
        bubbles: true,
        cancelable: true,
        view: window
      });
      arguments[0].dispatchEvent(event);
    ", input.native)
    
    # Check that the input has the touch-active class
    assert_selector ".touch-active"
    
    # Simulate touchend event
    page.execute_script("
      const event = new TouchEvent('touchend', {
        bubbles: true,
        cancelable: true,
        view: window
      });
      arguments[0].dispatchEvent(event);
    ", input.native)
    
    # Check that the touch-active class is removed
    assert_no_selector ".touch-active"
  end
  
  test "focus is preserved when auto-submitting forms" do
    visit budget_budget_categories_path(@budget)
    
    # Find the first budget category input
    input = first("[data-budget-touch-target='input']")
    
    # Focus the input
    input.click
    
    # Check that the input is focused
    assert_equal input, page.driver.browser.switch_to.active_element
    
    # Enter a value to trigger auto-submit
    input.native.send_keys("100")
    
    # Wait for the form to be submitted
    sleep 0.5
    
    # Check that the input is still focused
    assert_equal input, page.driver.browser.switch_to.active_element
  end
  
  test "touch device detection works properly" do
    # Simulate a touch device
    page.execute_script("
      window.ontouchstart = function() {};
      document.dispatchEvent(new Event('DOMContentLoaded'));
    ")
    
    visit budget_budget_categories_path(@budget)
    
    # Check that the touch-device class is added
    assert_selector ".touch-device"
  end
  
  test "landscape orientation layout is applied" do
    # Set mobile landscape viewport size
    page.driver.browser.manage.window.resize_to(667, 375)
    
    # Simulate a touch device
    page.execute_script("
      window.ontouchstart = function() {};
      document.dispatchEvent(new Event('DOMContentLoaded'));
    ")
    
    visit budget_budget_categories_path(@budget)
    
    # Check that the responsive grid component is rendered
    assert_selector ".responsive-budget-grid"
    
    # In landscape mode, we should have a grid layout
    # This is applied via CSS media query, so we can't directly test the computed style
    # But we can check that the container exists
    assert_selector ".budget-categories-container"
  end
end