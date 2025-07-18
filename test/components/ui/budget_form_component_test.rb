# frozen_string_literal: true

require "test_helper"

class Ui::BudgetFormComponentTest < ViewComponent::TestCase
  test "renders budget form with proper theme-aware styling" do
    budget = budgets(:one)
    
    render_inline(Ui::BudgetFormComponent.new(budget: budget))
    
    # Check for form elements
    assert_selector "form[data-controller='budget-form']"
    assert_selector "input[name='budget[budgeted_spending]']"
    assert_selector "input[name='budget[expected_income]']"
    assert_selector "button[type='submit']"
    
    # Check for theme-aware classes
    assert_selector ".bg-background"
    assert_selector ".text-primary"
    assert_selector ".text-muted-foreground"
    assert_selector ".border-border"
  end
  
  test "renders auto-suggest toggle when estimates are available" do
    budget = budgets(:one)
    budget.stubs(:estimated_income).returns(5000)
    budget.stubs(:estimated_spending).returns(4000)
    
    render_inline(Ui::BudgetFormComponent.new(budget: budget))
    
    assert_selector "input[type='checkbox'][id='auto_fill']"
    assert_selector ".peer-checked\\:bg-primary" # Theme-aware toggle styling
  end
  
  test "renders error messages when budget has errors" do
    budget = budgets(:one)
    budget.errors.add(:budgeted_spending, "can't be blank")
    
    render_inline(Ui::BudgetFormComponent.new(budget: budget))
    
    assert_selector ".border-destructive"
    assert_selector ".text-destructive"
    assert_text "can't be blank"
  end
end