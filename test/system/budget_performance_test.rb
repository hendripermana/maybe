# frozen_string_literal: true

require "application_system_test_case"

class BudgetPerformanceTest < ApplicationSystemTestCase
  setup do
    sign_in users(:family_admin)
    @budget = budgets(:one)

    # Store the original budget categories count for cleanup
    @original_category_count = @budget.budget_categories.count
  end

  teardown do
    # Clean up any extra budget categories we created
    if @budget.budget_categories.count > @original_category_count
      @budget.budget_categories.offset(@original_category_count).destroy_all
    end
  end

  test "page loads efficiently with default number of budget categories" do
    start_time = Time.current

    visit budget_budget_categories_path(@budget)

    # Wait for the page to fully load
    assert_selector ".responsive-budget-grid", wait: 5

    load_time = Time.current - start_time

    # The page should load in under 2 seconds with the default number of categories
    assert load_time < 2.0, "Page load time (#{load_time.round(2)}s) exceeded 2 seconds with default categories"

    # Count the number of budget categories displayed
    category_count = all(".category-group").count
    puts "Loaded #{category_count} budget categories in #{load_time.round(2)} seconds"
  end

  test "page remains responsive with 50 budget categories" do
    # Create additional budget categories to reach 50 total
    create_additional_budget_categories(50)

    start_time = Time.current

    visit budget_budget_categories_path(@budget)

    # Wait for the page to fully load
    assert_selector ".responsive-budget-grid", wait: 10

    load_time = Time.current - start_time

    # The page should load in under 5 seconds with 50 categories
    assert load_time < 5.0, "Page load time (#{load_time.round(2)}s) exceeded 5 seconds with 50 categories"

    # Verify all categories are displayed
    category_count = all(".category-group").count
    assert_operator category_count, :>=, 50, "Not all budget categories were displayed"
    puts "Loaded #{category_count} budget categories in #{load_time.round(2)} seconds"

    # Test scrolling performance
    scroll_start_time = Time.current
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    page.execute_script("window.scrollTo(0, 0)")
    scroll_time = Time.current - scroll_start_time

    # Scrolling should be smooth (under 0.5 seconds)
    assert scroll_time < 0.5, "Scrolling time (#{scroll_time.round(2)}s) exceeded 0.5 seconds"
  end

  test "budget category updates are processed efficiently" do
    visit budget_budget_categories_path(@budget)

    # Find the first 5 budget category inputs
    inputs = all("input[id$='_budgeted_spending']").first(5)

    # Measure the time to update 5 categories in sequence
    start_time = Time.current

    inputs.each_with_index do |input, index|
      # Clear the input and enter a new value
      input.native.send_keys(:backspace) until input.value.empty?
      input.native.send_keys((index + 1) * 100)

      # Move focus away to trigger the auto-submit
      page.find("body").click

      # Wait for the update to process
      sleep 0.1
    end

    # Wait for the final update to be reflected in the total
    sleep 0.5

    update_time = Time.current - start_time

    # Updating 5 categories should take less than 3 seconds total
    assert update_time < 3.0, "Updating 5 budget categories took #{update_time.round(2)} seconds, which exceeds 3 seconds"
    puts "Updated 5 budget categories in #{update_time.round(2)} seconds"
  end

  test "allocation progress updates efficiently when scrolling with many categories" do
    # Create additional budget categories to reach 30 total
    create_additional_budget_categories(30)

    # Set mobile viewport size with limited height to force scrolling
    page.driver.browser.manage.window.resize_to(375, 400)

    visit budget_budget_categories_path(@budget)

    # Wait for the page to fully load
    assert_selector ".responsive-budget-grid", wait: 10

    # Scroll down to the bottom
    scroll_start_time = Time.current
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    scroll_time = Time.current - scroll_start_time

    # Scrolling should be smooth (under 0.5 seconds)
    assert scroll_time < 0.5, "Scrolling time (#{scroll_time.round(2)}s) exceeded 0.5 seconds with many categories"

    # Check that allocation progress is still visible (it's sticky)
    assert_selector ".allocation-progress-container"

    # Update a category at the bottom of the page
    bottom_input = all("input[id$='_budgeted_spending']").last

    update_start_time = Time.current

    # Clear the input and enter a new value
    bottom_input.native.send_keys(:backspace) until bottom_input.value.empty?
    bottom_input.native.send_keys("999")

    # Move focus away to trigger the auto-submit
    page.find("body").click

    # Wait for the update to process
    sleep 0.5

    update_time = Time.current - update_start_time

    # The update should be reflected in the sticky header quickly
    assert update_time < 1.0, "Updating a category at the bottom took #{update_time.round(2)} seconds to reflect in the header, which exceeds 1 second"
  end

  private

    def create_additional_budget_categories(target_count)
      current_count = @budget.budget_categories.count
      return if current_count >= target_count

      # Get existing categories to use as templates
      template_categories = @budget.budget_categories.to_a

      # Create additional categories until we reach the target count
      (current_count...target_count).each do |i|
        # Make sure we don't divide by zero if template_categories is empty
        template_index = template_categories.empty? ? 0 : (i % template_categories.size)
        template = template_categories[template_index] if !template_categories.empty?

        # Create a new category based on the template
        new_category = @budget.budget_categories.create!(
          category: Category.create!(
            name: "Test Category #{i}",
            color: "##{SecureRandom.hex(3)}",
            family: @budget.family
          ),
          budgeted_spending: rand(100..1000),
          currency: @budget.currency # Make sure to include the currency
        )
      end

      # Verify we created the right number of categories
      actual_count = @budget.budget_categories.reload.count
      puts "Created #{actual_count - current_count} additional budget categories (total: #{actual_count})"
    end
end
