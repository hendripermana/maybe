# frozen_string_literal: true

require "application_system_test_case"

class BudgetInteractionsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:family_admin)
    @budget = budgets(:one)
  end

  test "can update budget category amounts" do
    visit budget_budget_categories_path(@budget)

    # Find the first budget category input
    input = first("input[id$='_budgeted_spending']")
    original_value = input.value.to_f
    new_value = original_value + 100

    # Clear the input and enter the new value
    input.native.send_keys(:backspace) until input.value.empty?
    input.native.send_keys(new_value.to_s)

    # Move focus away to trigger the auto-submit
    page.find("body").click

    # Wait for the update to process
    sleep 0.5

    # Reload the page to verify the change persisted
    visit budget_budget_categories_path(@budget)

    # Find the same input again
    updated_input = first("input[id$='_budgeted_spending']")

    # Verify the value was updated and persisted
    assert_in_delta new_value, updated_input.value.to_f, 0.01, "Budget category amount wasn't updated correctly"
  end

  test "allocation progress updates when budget category is changed" do
    visit budget_budget_categories_path(@budget)

    # Get initial allocation progress
    initial_progress_element = find(".allocation-progress-container progress")
    initial_progress_value = initial_progress_element["value"].to_f

    # Find the first budget category input and update its value
    input = first("input[id$='_budgeted_spending']")
    original_value = input.value.to_f
    new_value = original_value + 100

    # Clear the input and enter the new value
    input.native.send_keys(:backspace) until input.value.empty?
    input.native.send_keys(new_value.to_s)

    # Move focus away to trigger the auto-submit
    page.find("body").click

    # Wait for the update to process
    sleep 0.5

    # Get the updated allocation progress
    updated_progress_element = find(".allocation-progress-container progress")
    updated_progress_value = updated_progress_element["value"].to_f

    # Verify the progress value increased
    assert_operator updated_progress_value, :>, initial_progress_value, "Allocation progress didn't increase after increasing a budget category amount"
  end

  test "confirm button is disabled when allocations are invalid" do
    # First, make sure the budget has valid allocations
    @budget.update(budgeted_spending: 10000)

    visit budget_budget_categories_path(@budget)

    # Set all budget category inputs to zero to make allocations valid
    all("input[id$='_budgeted_spending']").each do |input|
      input.native.send_keys(:backspace) until input.value.empty?
      input.native.send_keys("0")
      # Move focus away to trigger the auto-submit
      page.find("body").click
      sleep 0.1
    end

    # Wait for all updates to process
    sleep 0.5

    # Now set one input to a value higher than the budget to make allocations invalid
    input = first("input[id$='_budgeted_spending']")
    input.native.send_keys(:backspace) until input.value.empty?
    input.native.send_keys("20000") # Higher than the budget amount

    # Move focus away to trigger the auto-submit
    page.find("body").click

    # Wait for the update to process
    sleep 0.5

    # Check if the confirm button is disabled
    confirm_button = find(".confirm-button-container button")
    assert confirm_button.disabled?, "Confirm button should be disabled when allocations are invalid"
  end

  test "can navigate between budget categories using keyboard" do
    visit budget_budget_categories_path(@budget)

    # Focus the first input
    first_input = first("input[id$='_budgeted_spending']")
    first_input.click

    # Enter a value
    first_input.native.send_keys(:backspace) until first_input.value.empty?
    first_input.native.send_keys("100")

    # Press Tab to move to the next input
    first_input.native.send_keys(:tab)

    # Get the currently focused element
    focused_element = page.evaluate_script("document.activeElement.tagName")

    # Verify we moved to another input
    assert_equal "INPUT", focused_element, "Focus didn't move to another input after pressing Tab"

    # Enter a value in the second input
    page.driver.browser.action.send_keys("200").perform

    # Wait for the update to process
    sleep 0.5

    # Verify both inputs have the expected values
    assert_equal "100", first_input.value
    assert_equal "200", page.evaluate_script("document.activeElement.value")
  end

  test "touch interactions work properly on budget forms" do
    # Skip this test if not running in a browser that supports touch events
    skip "Touch events not supported in current test environment" unless page.driver.browser.respond_to?(:action)

    # Set mobile viewport size
    page.driver.browser.manage.window.resize_to(375, 667)

    visit budget_budget_categories_path(@budget)

    # Find the first budget category input
    input = first("input[id$='_budgeted_spending']")

    # Simulate touch interaction
    page.driver.browser.action.move_to(input.native).click.perform

    # Check that the input is focused
    assert_equal input, page.driver.browser.switch_to.active_element

    # Enter a value
    input.native.send_keys("100")

    # Check that the value was entered
    assert_equal "100", input.value
  end

  test "budget category groups expand and collapse correctly" do
    # Skip if the budget page doesn't have collapsible groups
    skip "Budget page doesn't have collapsible groups" unless has_css?(".category-group-header[data-action*='click->collapsible#toggle']")

    visit budget_budget_categories_path(@budget)

    # Find a category group with subcategories
    group_header = first(".category-group-header[data-action*='click->collapsible#toggle']")

    # Skip if no collapsible groups found
    skip "No collapsible category groups found" unless group_header

    # Check if the group is initially expanded
    group_content = find("##{group_header['aria-controls']}")
    initially_expanded = group_content.visible?

    # Click the group header to toggle
    group_header.click

    # Wait for animation
    sleep 0.3

    # Verify the group toggled correctly
    if initially_expanded
      assert_not group_content.visible?, "Category group didn't collapse when clicked"
    else
      assert group_content.visible?, "Category group didn't expand when clicked"
    end

    # Click again to toggle back
    group_header.click

    # Wait for animation
    sleep 0.3

    # Verify it toggled back
    assert_equal initially_expanded, group_content.visible?, "Category group didn't toggle back to original state"
  end

  test "auto-suggest feature works correctly" do
    # Skip if the budget form doesn't have auto-suggest
    visit budget_path(@budget)

    # Check if auto-suggest toggle exists
    if has_css?("#auto_fill")
      # Click the auto-suggest toggle
      find("#auto_fill").click

      # Wait for the form to update
      sleep 0.5

      # Verify the form fields were populated
      expected_income_input = find("#budget_expected_income")
      budgeted_spending_input = find("#budget_budgeted_spending")

      assert expected_income_input.value.present?, "Expected income field wasn't populated by auto-suggest"
      assert budgeted_spending_input.value.present?, "Budgeted spending field wasn't populated by auto-suggest"
    else
      skip "Budget form doesn't have auto-suggest feature"
    end
  end

  test "budget form validation works correctly" do
    visit budget_path(@budget)

    # Try to submit the form with invalid values
    within("form[data-controller='budget-form']") do
      # Clear the required fields
      fill_in "budget_budgeted_spending", with: ""
      fill_in "budget_expected_income", with: ""

      # Submit the form
      click_button "Continue"
    end

    # Check for validation errors
    assert_selector ".text-destructive", text: /can't be blank/i

    # Fill in valid values
    within("form[data-controller='budget-form']") do
      fill_in "budget_budgeted_spending", with: "1000"
      fill_in "budget_expected_income", with: "2000"

      # Submit the form
      click_button "Continue"
    end

    # Verify we were redirected to the budget categories page
    assert_current_path(/budget_categories/, wait: 5)
  end
end
