# frozen_string_literal: true
require "test_helper"

class TransactionItemComponentTest < ComprehensiveComponentTestCase
  include MasterComponentTestingSuite
  
  setup do
    @transaction = transactions(:one)
    @component = TransactionItemComponent.new(transaction: @transaction)
  end
  
  test "renders transaction item with default options" do
    render_inline(@component)
    
    assert_selector ".transaction-item"
    assert_text @transaction.description
    assert_text @transaction.amount.format
  end
  
  test "renders transaction item with category" do
    @transaction.category = categories(:food)
    render_inline(TransactionItemComponent.new(transaction: @transaction))
    
    assert_selector ".transaction-item"
    assert_selector ".transaction-category", text: @transaction.category.name
  end
  
  test "renders transaction item with merchant" do
    @transaction.merchant = merchants(:amazon)
    render_inline(TransactionItemComponent.new(transaction: @transaction))
    
    assert_selector ".transaction-item"
    assert_selector ".transaction-merchant", text: @transaction.merchant.name
  end
  
  test "renders transaction item with tags" do
    @transaction.tags << tags(:groceries)
    render_inline(TransactionItemComponent.new(transaction: @transaction))
    
    assert_selector ".transaction-item"
    assert_selector ".transaction-tag", text: tags(:groceries).name
  end
  
  test "renders transaction item with proper theme awareness" do
    test_theme_switching(@component)
    
    # Check for theme-aware classes
    assert_component_theme_aware(@component)
    
    # Check for no hardcoded colors
    render_inline(@component)
    assert_no_hardcoded_theme_classes
  end
  
  test "transaction item meets accessibility requirements" do
    render_inline(@component)
    
    # Check for proper semantic structure
    assert_selector "div.transaction-item", count: 1
    
    # Check for proper text contrast
    assert_css_variables_used
  end
  
  test "transaction item handles interactions correctly" do
    render_inline(TransactionItemComponent.new(
      transaction: @transaction,
      data: { action: "click->transaction#select" }
    ))
    
    # Check for click handler
    assert_selector "[data-action*='click->transaction#select']"
  end
  
  # Comprehensive test using our testing suite
  test "transaction item passes comprehensive component testing" do
    test_component_comprehensively(
      @component,
      interactions: [:click, :hover]
    )
  end
  
  # Test different transaction states
  test "renders different transaction states correctly" do
    # Pending transaction
    @transaction.status = "pending"
    render_inline(TransactionItemComponent.new(transaction: @transaction))
    assert_selector ".transaction-item.transaction-pending"
    
    # Cleared transaction
    @transaction.status = "cleared"
    render_inline(TransactionItemComponent.new(transaction: @transaction))
    assert_selector ".transaction-item.transaction-cleared"
  end
  
  # Test income vs expense styling
  test "renders income and expense transactions differently" do
    # Income transaction
    @transaction.amount = Money.new(1000, "USD")
    render_inline(TransactionItemComponent.new(transaction: @transaction))
    assert_selector ".transaction-amount.text-success"
    
    # Expense transaction
    @transaction.amount = Money.new(-1000, "USD")
    render_inline(TransactionItemComponent.new(transaction: @transaction))
    assert_selector ".transaction-amount.text-danger"
  end
end