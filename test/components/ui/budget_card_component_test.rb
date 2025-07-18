require "test_helper"

class UI::BudgetCardComponentTest < ViewComponent::TestCase
  def setup
    @family = families(:demo)
    @budget = budgets(:demo_current)
    @category = categories(:groceries)
    @budget_category = budget_categories(:demo_groceries)
  end
  
  def test_renders_budget_card
    render_inline(UI::BudgetCardComponent.new(budget_category: @budget_category))
    
    assert_text(@category.name)
    assert_link(href: budget_budget_category_path(@budget, @budget_category))
  end
  
  def test_renders_under_budget_status
    @budget_category.stubs(:available_to_spend).returns(Money.new(5000, "USD"))
    @budget_category.stubs(:percent_of_budget_spent).returns(50)
    
    render_inline(UI::BudgetCardComponent.new(budget_category: @budget_category))
    
    assert_selector(".text-green-500")
    assert_text("$50.00 left")
  end
  
  def test_renders_on_budget_status
    @budget_category.stubs(:available_to_spend).returns(Money.new(500, "USD"))
    @budget_category.stubs(:percent_of_budget_spent).returns(95)
    
    render_inline(UI::BudgetCardComponent.new(budget_category: @budget_category))
    
    assert_selector(".text-yellow-500")
    assert_text("$5.00 left")
  end
  
  def test_renders_over_budget_status
    @budget_category.stubs(:available_to_spend).returns(Money.new(-2000, "USD"))
    @budget_category.stubs(:percent_of_budget_spent).returns(120)
    
    render_inline(UI::BudgetCardComponent.new(budget_category: @budget_category))
    
    assert_selector(".text-red-500")
    assert_text("$20.00 over")
  end
  
  def test_renders_progress_bar_when_initialized
    @budget_category.stubs(:initialized?).returns(true)
    @budget_category.stubs(:budgeted_spending).returns(10000)
    
    render_inline(UI::BudgetCardComponent.new(budget_category: @budget_category))
    
    assert_selector("div[role='progressbar']")
  end
  
  def test_does_not_render_progress_bar_when_not_initialized
    @budget_category.stubs(:initialized?).returns(false)
    
    render_inline(UI::BudgetCardComponent.new(budget_category: @budget_category))
    
    assert_no_selector("div[role='progressbar']")
  end
end