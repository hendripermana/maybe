# frozen_string_literal: true

require "application_system_test_case"

class BudgetFormAccessibilityTest < ApplicationSystemTestCase
  setup do
    sign_in users(:john)
    @budget = budgets(:january)
  end

  test "budget form is accessible with keyboard navigation" do
    visit edit_budget_path(@budget)
    
    # Test keyboard navigation through form fields
    find("input#budget_budgeted_spending").click
    page.driver.browser.action.send_keys(:tab).perform
    assert_equal find("input#budget_expected_income"), page.driver.browser.switch_to.active_element
    
    page.driver.browser.action.send_keys(:tab).perform
    if has_css?("input#auto_fill")
      assert_equal find("input#auto_fill"), page.driver.browser.switch_to.active_element
      page.driver.browser.action.send_keys(:tab).perform
    end
    
    assert_equal find("button[type='submit']"), page.driver.browser.switch_to.active_element
  end

  test "budget form has proper focus states" do
    visit edit_budget_path(@budget)
    
    # Test focus states
    find("input#budget_budgeted_spending").click
    assert_selector "input#budget_budgeted_spending:focus-visible"
    
    find("input#budget_expected_income").click
    assert_selector "input#budget_expected_income:focus-visible"
    
    find("button[type='submit']").click
    assert_selector "button[type='submit']:focus-visible"
  end

  test "budget category form is accessible with keyboard navigation" do
    visit budget_budget_categories_path(@budget)
    
    # Find the first budget category input
    first_input = first("input[id$='_budgeted_spending']")
    first_input.click
    
    # Test keyboard navigation through category inputs
    page.driver.browser.action.send_keys(:tab).perform
    next_element = page.driver.browser.switch_to.active_element
    assert next_element.attribute("id").end_with?("_budgeted_spending")
  end

  test "budget form works in both light and dark themes" do
    # Test in light theme
    visit edit_budget_path(@budget)
    assert_selector ".bg-background"
    
    # Switch to dark theme (assuming there's a theme toggle)
    if has_css?("[data-action*='theme#toggle']")
      find("[data-action*='theme#toggle']").click
      assert_selector "[data-theme='dark']"
      
      # Verify form elements are visible in dark theme
      assert_selector "input#budget_budgeted_spending"
      assert_selector "input#budget_expected_income"
      assert_selector "button[type='submit']"
    end
  end
end