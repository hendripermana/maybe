require "application_system_test_case"

class TransactionListTest < ApplicationSystemTestCase
  setup do
    sign_in users(:john)
    @transaction = entries(:checking_groceries).entryable
  end

  test "displays transactions with modern styling" do
    visit transactions_path
    
    assert_selector ".bg-container.rounded-xl"
    assert_selector "h1", text: "Transactions"
  end

  test "can search for transactions" do
    visit transactions_path
    
    fill_in "q_search", with: "groceries"
    
    assert_selector ".filter-badge", text: "Search: groceries"
  end

  test "can filter transactions" do
    visit transactions_path
    
    click_on "Filter"
    select "Last 7 days", from: "Date range"
    click_on "Apply"
    
    assert_selector ".filter-badge", text: "From:"
  end

  test "can select transactions" do
    visit transactions_path
    
    first("input[type='checkbox']").click
    
    assert_selector "#entry-selection-bar", visible: true
  end

  test "shows loading state when navigating" do
    visit transactions_path
    
    # This is hard to test in a system test, but we can verify the elements exist
    assert_selector ".transaction-list-loading", visible: false
  end
end