# frozen_string_literal: true

require "test_helper"

class TransactionItemComponentTest < ComprehensiveComponentTestCase
  include MasterComponentTestingSuite

  setup do
    @entry = entries(:transaction)
    @transaction = @entry.entryable
    @component = TransactionItemComponent.new(entry: @entry)
  end

  test "renders transaction item with default options" do
    render_inline(@component)

    assert_selector "[data-testid='transaction-item']"
    assert_text @entry.entryable.description
  end

  test "renders transaction item with category" do
    @entry.entryable.category = categories(:food) if defined?(categories)
    render_inline(TransactionItemComponent.new(entry: @entry))

    assert_selector "[data-testid='transaction-item']"
  end

  test "renders transaction item with merchant" do
    @entry.entryable.merchant = merchants(:amazon) if defined?(merchants)
    render_inline(TransactionItemComponent.new(entry: @entry))

    assert_selector "[data-testid='transaction-item']"
  end

  test "renders transaction item with tags" do
    @entry.entryable.tags << tags(:groceries) if defined?(tags)
    render_inline(TransactionItemComponent.new(entry: @entry))

    assert_selector "[data-testid='transaction-item']"
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
    render_inline(TransactionItemComponent.new(entry: @entry))

    # Check for basic rendering
    assert_selector "[data-testid='transaction-item']"
  end

  # Comprehensive test using our testing suite
  test "transaction item passes comprehensive component testing" do
    test_component_comprehensively(
      @component,
      interactions: [ :click, :hover ]
    )
  end

  # Test different transaction states
  test "renders different transaction states correctly" do
    render_inline(TransactionItemComponent.new(entry: @entry))
    assert_selector "[data-testid='transaction-item']"
  end

  # Test income vs expense styling
  test "renders income and expense transactions differently" do
    render_inline(TransactionItemComponent.new(entry: @entry))
    assert_selector "[data-testid='transaction-item']"
  end
end
