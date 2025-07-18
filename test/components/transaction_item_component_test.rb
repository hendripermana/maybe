require "test_helper"

class TransactionItemComponentTest < ViewComponent::TestCase
  setup do
    @entry = entries(:checking_groceries)
    @transaction = @entry.entryable
  end

  test "renders transaction item with proper styling" do
    render_inline(TransactionItemComponent.new(entry: @entry))
    
    assert_selector ".grid.grid-cols-12"
    assert_selector "a", text: @entry.name
    assert_selector "p", text: format_money(-@entry.amount_money)
  end

  test "renders selected state" do
    render_inline(TransactionItemComponent.new(entry: @entry, selected: true))
    
    assert_selector ".bg-primary-50"
  end

  test "renders excluded transaction with reduced opacity" do
    @entry.update(excluded: true)
    render_inline(TransactionItemComponent.new(entry: @entry))
    
    assert_selector ".opacity-50"
  end

  test "renders merchant logo when available" do
    merchant = merchants(:amazon)
    merchant.update(logo_url: "https://example.com/logo.png")
    @transaction.update(merchant: merchant)
    
    render_inline(TransactionItemComponent.new(entry: @entry))
    
    assert_selector "img[src='https://example.com/logo.png']"
  end

  test "renders fallback icon when no merchant logo" do
    render_inline(TransactionItemComponent.new(entry: @entry))
    
    assert_selector ".filled-icon"
  end

  test "renders one-time indicator for one-time transactions" do
    @transaction.update(kind: "one_time")
    render_inline(TransactionItemComponent.new(entry: @entry))
    
    assert_selector ".text-orange-500"
  end
end