# frozen_string_literal: true

require "application_system_test_case"

class BudgetCalculationsTest < ApplicationSystemTestCase
  setup do
    sign_in users(:family_admin)
    @budget = budgets(:one)
  end

  test "budget allocation calculations are accurate" do
    visit budget_budget_categories_path(@budget)

    # Get the total budgeted amount from the UI
    total_budgeted_element = find(".allocation-progress-container .total-budgeted")
    total_budgeted_ui = extract_amount_from_text(total_budgeted_element.text)

    # Calculate the expected total by summing all budget category inputs
    expected_total = 0
    all("input[id$='_budgeted_spending']").each do |input|
      expected_total += input.value.to_f if input.value.present?
    end

    # Verify the displayed total matches our calculation
    assert_in_delta expected_total, total_budgeted_ui, 0.01, "Budget allocation total displayed doesn't match the sum of individual categories"

    # Also verify against the database value
    assert_in_delta @budget.reload.allocated_spending, total_budgeted_ui, 0.01, "Budget allocation total displayed doesn't match the database value"
  end

  test "budget remaining amount calculations are accurate" do
    visit budget_budget_categories_path(@budget)

    # Get the remaining amount from the UI
    remaining_element = find(".allocation-progress-container .remaining-amount")
    remaining_ui = extract_amount_from_text(remaining_element.text)

    # Calculate the expected remaining amount
    total_budgeted_element = find(".allocation-progress-container .total-budgeted")
    total_budgeted_ui = extract_amount_from_text(total_budgeted_element.text)
    expected_remaining = @budget.budgeted_spending - total_budgeted_ui

    # Verify the displayed remaining amount matches our calculation
    assert_in_delta expected_remaining, remaining_ui, 0.01, "Remaining budget amount displayed doesn't match the expected calculation"

    # Also verify against the database value
    assert_in_delta @budget.reload.available_to_allocate, remaining_ui, 0.01, "Remaining budget amount displayed doesn't match the database value"
  end

  test "budget progress bar percentage is accurate" do
    visit budget_budget_categories_path(@budget)

    # Get the progress bar value from the aria attributes
    progress_bar = find("#allocation-progress-bar", visible: false)
    progress_value = progress_bar["aria-valuenow"].to_f
    progress_max = progress_bar["aria-valuemax"].to_f
    progress_percentage = (progress_value / progress_max) * 100

    # Calculate the expected percentage
    total_budgeted_element = find(".allocation-progress-container .total-budgeted")
    total_budgeted_ui = extract_amount_from_text(total_budgeted_element.text)
    expected_percentage = (total_budgeted_ui / @budget.budgeted_spending) * 100

    # Verify the progress bar percentage matches our calculation
    assert_in_delta expected_percentage, progress_percentage, 1.0, "Progress bar percentage doesn't match the expected calculation"
  end

  test "updating a budget category updates the total and remaining amounts" do
    visit budget_budget_categories_path(@budget)

    # Get initial values
    initial_total_element = find(".allocation-progress-container .total-budgeted")
    initial_total = extract_amount_from_text(initial_total_element.text)

    # Find all budget category inputs
    inputs = all("input[id$='_budgeted_spending']")

    # Skip the test if no inputs are found
    skip "No budget category inputs found" if inputs.empty?

    # Use the first non-disabled input
    input = inputs.find { |i| !i.disabled? }

    # Skip the test if no non-disabled inputs are found
    skip "No editable budget category inputs found" unless input

    original_value = input.value.to_f
    new_value = original_value + 100

    # Clear the input and enter the new value
    input.native.send_keys(:backspace) until input.value.empty?
    input.native.send_keys(new_value.to_s)

    # Move focus away to trigger the auto-submit
    page.find("body").click

    # Wait for the update to process
    sleep 0.5

    # Get the updated total
    updated_total_element = find(".allocation-progress-container .total-budgeted")
    updated_total = extract_amount_from_text(updated_total_element.text)

    # Verify the total increased by the expected amount
    expected_total = initial_total + 100
    assert_in_delta expected_total, updated_total, 0.01, "Total budgeted amount didn't update correctly after changing a category value"
  end

  test "budget calculations handle zero values correctly" do
    visit budget_budget_categories_path(@budget)

    # Set all budget category inputs to zero
    all("input[id$='_budgeted_spending']").each do |input|
      input.native.send_keys(:backspace) until input.value.empty?
      input.native.send_keys("0")
      # Move focus away to trigger the auto-submit
      page.find("body").click
      sleep 0.1
    end

    # Wait for all updates to process
    sleep 0.5

    # Get the updated total
    total_budgeted_element = find(".allocation-progress-container .total-budgeted")
    total_budgeted_ui = extract_amount_from_text(total_budgeted_element.text)

    # Verify the total is zero
    assert_in_delta 0, total_budgeted_ui, 0.01, "Total budgeted amount should be zero when all categories are zero"

    # Verify the remaining amount is the full budget amount
    remaining_element = find(".allocation-progress-container .remaining-amount")
    remaining_ui = extract_amount_from_text(remaining_element.text)
    assert_in_delta @budget.budgeted_spending, remaining_ui, 0.01, "Remaining amount should be the full budget amount when all categories are zero"
  end

  private

    def extract_amount_from_text(text)
      # Extract numeric value from text like "$1,234.56" or "1,234.56"
      text.gsub(/[^\d.]/, "").to_f
    end
end
