require "application_system_test_case"

class BudgetComponentsTest < ApplicationSystemTestCase
  setup do
    @family = families(:demo)
    @user = users(:demo)
    @budget = budgets(:demo_current)

    sign_in @user
  end

  test "renders progress bar component with proper styling" do
    visit lookbook_path("/components/ui/progress_bar_component/default")

    assert_selector "div[role='progressbar']"
    assert_selector "div.bg-primary" # Default variant
  end

  test "renders budget card component with proper styling" do
    visit lookbook_path("/components/ui/budget_card_component/default")

    assert_selector ".bg-card" # Card background
    assert_selector "h3.text-sm.font-medium" # Category name
    assert_selector "div[role='progressbar']" # Progress bar
  end

  test "budget card shows different status indicators" do
    visit lookbook_path("/components/ui/budget_card_component/status_variants")

    # Under budget (green)
    assert_selector ".text-green-500"

    # On budget (yellow)
    assert_selector ".text-yellow-500"

    # Over budget (red)
    assert_selector ".text-red-500"
  end

  test "budget card handles subcategories properly" do
    visit lookbook_path("/components/ui/budget_card_component/with_subcategories")

    # Parent category
    assert_text "Food"

    # Subcategories with proper indentation
    assert_selector ".ml-8"
    assert_text "Groceries"
    assert_text "Dining Out"
  end

  test "budget card handles uninitialized budgets" do
    visit lookbook_path("/components/ui/budget_card_component/uninitialized_budget")

    assert_text "Transportation"
    assert_text "$150.00 avg" # Shows average instead of remaining
    assert_no_selector "div[role='progressbar']" # No progress bar for uninitialized
  end
end
