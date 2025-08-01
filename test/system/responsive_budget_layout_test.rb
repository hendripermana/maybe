# frozen_string_literal: true

require "application_system_test_case"

class ResponsiveBudgetLayoutTest < ApplicationSystemTestCase
  setup do
    sign_in users(:family_admin)
    @budget = budgets(:one)
  end

  test "budget categories display properly on desktop" do
    # Set desktop viewport size
    page.driver.browser.manage.window.resize_to(1200, 800)

    visit budget_budget_categories_path(@budget)

    # Check that the responsive grid component is rendered
    assert_selector ".responsive-budget-grid"

    # Check that allocation progress is visible
    assert_selector ".allocation-progress-container"

    # Check that category groups are displayed
    assert_selector ".category-group"

    # Check that subcategories have proper indentation
    if has_css?(".subcategories-container")
      assert_selector ".subcategory-item"
    end

    # Check that confirm button is visible
    assert_selector ".confirm-button-container"
  end

  test "budget categories display properly on tablet" do
    # Set tablet viewport size
    page.driver.browser.manage.window.resize_to(768, 1024)

    visit budget_budget_categories_path(@budget)

    # Check that the responsive grid component is rendered
    assert_selector ".responsive-budget-grid"

    # Check that allocation progress is visible
    assert_selector ".allocation-progress-container"

    # Check that category groups are displayed
    assert_selector ".category-group"

    # Check that subcategories have proper indentation
    if has_css?(".subcategories-container")
      assert_selector ".subcategory-item"
    end

    # Check that confirm button is visible
    assert_selector ".confirm-button-container"
  end

  test "budget categories display properly on mobile" do
    # Set mobile viewport size
    page.driver.browser.manage.window.resize_to(375, 667)

    visit budget_budget_categories_path(@budget)

    # Check that the responsive grid component is rendered
    assert_selector ".responsive-budget-grid"

    # Check that allocation progress is visible
    assert_selector ".allocation-progress-container"

    # Check that category groups are displayed
    assert_selector ".category-group"

    # Check that subcategories have proper indentation
    if has_css?(".subcategories-container")
      assert_selector ".subcategory-item"
    end

    # Check that confirm button is visible
    assert_selector ".confirm-button-container"

    # Check that elements are stacked properly on mobile
    # This is a bit tricky to test directly, but we can check for the flex-wrap class
    assert_selector ".flex-wrap"
  end

  test "budget categories display properly in landscape orientation" do
    # Set mobile landscape viewport size
    page.driver.browser.manage.window.resize_to(667, 375)

    visit budget_budget_categories_path(@budget)

    # Check that the responsive grid component is rendered
    assert_selector ".responsive-budget-grid"

    # Check that allocation progress is visible
    assert_selector ".allocation-progress-container"

    # Check that category groups are displayed
    assert_selector ".category-group"

    # Check that confirm button is visible
    assert_selector ".confirm-button-container"
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

  test "allocation progress remains visible when scrolling" do
    # Set mobile viewport size with limited height to force scrolling
    page.driver.browser.manage.window.resize_to(375, 400)

    visit budget_budget_categories_path(@budget)

    # Scroll down to the bottom
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")

    # Check that allocation progress is still visible (it's sticky)
    assert_selector ".allocation-progress-container"

    # Check that confirm button is visible (it's sticky at bottom)
    assert_selector ".confirm-button-container"
  end
end
