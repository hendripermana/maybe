# frozen_string_literal: true

require "test_helper"

class Ui::BudgetCategoryFormComponentTest < ViewComponent::TestCase
  test "renders budget category form with proper theme-aware styling" do
    budget_category = budget_categories(:groceries_january)

    render_inline(Ui::BudgetCategoryFormComponent.new(budget_category: budget_category))

    # Check for form elements
    assert_selector "form[data-controller='auto-submit-form preserve-focus']"
    assert_selector "input[name='budget_category[budgeted_spending]']"

    # Check for theme-aware classes
    assert_selector ".bg-background"
    assert_selector ".text-primary"
    assert_selector ".text-secondary"
    assert_selector ".focus-visible\\:ring-ring"
  end

  test "renders category color indicator" do
    budget_category = budget_categories(:groceries_january)
    color = budget_category.category.color

    render_inline(Ui::BudgetCategoryFormComponent.new(budget_category: budget_category))

    assert_selector "[style*='background-color: #{color}']"
  end

  test "renders average spending information" do
    budget_category = budget_categories(:groceries_january)
    budget_category.stubs(:median_monthly_expense_money).returns(Money.new(50000, "USD"))

    render_inline(Ui::BudgetCategoryFormComponent.new(budget_category: budget_category))

    assert_text "$500/m avg"
  end
end
