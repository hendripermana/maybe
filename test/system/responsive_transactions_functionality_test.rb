require "application_system_test_case"

class ResponsiveTransactionsFunctionalityTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "transaction list displays all expected elements" do
    visit transactions_path

    # Verify page structure
    assert_selector ".responsive-transaction-container", count: 1
    assert_selector ".responsive-transaction-filters", count: 1
    assert_selector ".responsive-transaction-list", count: 1

    # Skip if no transactions
    skip "No transactions found" unless has_selector?(".responsive-transaction-item")

    # Verify transaction items display correctly
    within ".responsive-transaction-list" do
      # Check for transaction name
      assert_selector ".responsive-transaction-item a", minimum: 1

      # Check for amount display
      assert_selector ".responsive-transaction-item [data-amount]", minimum: 1

      # Check for category display (might be hidden on mobile)
      assert has_selector?(".responsive-transaction-item [data-category]") ||
             has_selector?(".responsive-transaction-item .block.md\\:hidden [data-category]")
    end
  end

  test "transaction search functionality works" do
    visit transactions_path

    # Find search input
    search_input = find(".responsive-transaction-filters input[type='search']")

    # Enter search term
    search_term = "test"
    search_input.fill_in(with: search_term)

    # Submit search form
    find(".responsive-transaction-filters input[type='search']").native.send_keys(:return)

    # Wait for results to load
    sleep 1

    # Verify search results
    if has_selector?(".responsive-transaction-item")
      # Check that results contain search term (case insensitive)
      all(".responsive-transaction-item").each do |item|
        item_text = item.text.downcase
        assert item_text.include?(search_term.downcase),
               "Search result '#{item_text}' should contain '#{search_term}'"
      end
    else
      # If no results, verify empty state
      assert_selector ".responsive-transaction-list .empty-state",
                      text: /no transactions/i
    end
  end

  test "transaction filtering functionality works" do
    visit transactions_path

    # Open filters dropdown
    find(".responsive-transaction-filters button", text: "Filters").click

    # Wait for dropdown to appear
    assert_selector ".responsive-transaction-filters [data-disclosure-target='content']", visible: true

    # Select a category (if available)
    if has_selector?("#category_ids option")
      category_option = find("#category_ids option", match: :first)
      category_name = category_option.text
      category_option.select_option

      # Apply filters
      find("button", text: "Apply Filters").click

      # Wait for results to load
      sleep 1

      # Verify filter badge appears
      assert_selector ".responsive-transaction-filters [data-filter-badge]",
                      text: /#{category_name}/i
    else
      skip "No categories available for testing filters"
    end
  end

  test "transaction date range filtering works" do
    visit transactions_path

    # Open date range dropdown
    find(".responsive-transaction-filters button", text: "Date Range").click

    # Wait for dropdown to appear
    assert_selector ".responsive-transaction-filters [data-disclosure-target='content']", visible: true

    # Click on a preset date range
    find("button", text: "This Month").click

    # Apply date range
    find("button", text: "Apply").click

    # Wait for results to load
    sleep 1

    # Verify filter badge appears
    assert_selector ".responsive-transaction-filters [data-filter-badge]",
                    text: /this month/i
  end

  test "transaction bulk selection works" do
    visit transactions_path

    # Skip if no transactions
    skip "No transactions found" unless has_selector?(".responsive-transaction-item")

    # Select first two transactions
    checkboxes = all(".responsive-transaction-item input[type='checkbox']").take(2)
    checkboxes.each(&:check)

    # Verify bulk action bar appears
    assert_selector "[data-bulk-select-target='bar']", visible: true

    # Verify correct count of selected items
    assert_selector "[data-bulk-select-target='count']", text: "2"

    # Uncheck one transaction
    checkboxes.first.uncheck

    # Verify count updates
    assert_selector "[data-bulk-select-target='count']", text: "1"

    # Uncheck remaining transaction
    checkboxes.last.uncheck

    # Verify bulk action bar disappears
    assert_no_selector "[data-bulk-select-target='bar']", visible: true
  end

  test "transaction bulk update functionality works" do
    visit transactions_path

    # Skip if no transactions
    skip "No transactions found" unless has_selector?(".responsive-transaction-item", minimum: 2)

    # Select first two transactions
    checkboxes = all(".responsive-transaction-item input[type='checkbox']").take(2)
    checkboxes.each(&:check)

    # Verify bulk action bar appears
    assert_selector "[data-bulk-select-target='bar']", visible: true

    # Click bulk update button
    find("[data-bulk-select-target='bar'] button", text: "Update").click

    # Verify bulk update form appears
    assert_selector ".transaction-bulk-update-container", visible: true

    # Verify form has expected fields
    assert_selector "#bulk_update_category_id", visible: true
    assert_selector "#bulk_update_merchant_id", visible: true
    assert_selector "#bulk_update_tag_ids", visible: true
    assert_selector "#bulk_update_notes", visible: true

    # Close the dialog
    find("button", text: "Cancel").click

    # Verify dialog closes
    assert_no_selector ".transaction-bulk-update-container", visible: true
  end

  test "transaction creation form works" do
    visit transactions_path

    # Click new transaction button
    find("a", text: /new transaction/i, match: :first).click

    # Verify transaction form appears
    assert_selector ".transaction-form-container", visible: true

    # Verify form has expected fields
    assert_selector "#entry_name", visible: true
    assert_selector "#entry_amount", visible: true
    assert_selector "#entry_date", visible: true
    assert_selector "#entry_entryable_attributes_category_id", visible: true

    # Test form type toggle
    find("button", text: "Income").click

    # Verify category options change
    assert has_select?("entry[entryable_attributes][category_id]")

    # Test advanced fields toggle
    find("h3", text: "Additional Details").click

    # Verify advanced fields appear
    assert_selector "#entry_entryable_attributes_tag_ids", visible: true
    assert_selector "#entry_notes", visible: true

    # Close the form (by navigating back)
    page.go_back

    # Verify we're back at transactions list
    assert_selector ".responsive-transaction-container", visible: true
  end

  test "transaction editing functionality works" do
    visit transactions_path

    # Skip if no transactions
    skip "No transactions found" unless has_selector?(".responsive-transaction-item")

    # Click first transaction to edit
    find(".responsive-transaction-item a", match: :first).click

    # Verify transaction drawer appears
    assert_selector "[data-controller='dialog']", visible: true

    # Verify edit form appears
    assert_selector ".transaction-form-container", visible: true

    # Verify form has expected fields with values
    assert_selector "#entry_name[value]", visible: true
    assert_selector "#entry_amount[value]", visible: true
    assert_selector "#entry_date[value]", visible: true

    # Close the drawer
    find("button[aria-label='Close']").click

    # Verify drawer closes
    assert_no_selector "[data-controller='dialog']", visible: true
  end

  test "transaction pagination works" do
    # Create enough transactions to trigger pagination
    create_multiple_transactions(30)

    visit transactions_path

    # Verify pagination appears
    assert_selector "nav[aria-label='Pagination']"

    # Click next page
    if has_link?("Next")
      click_link "Next"

      # Verify page changes
      assert_selector ".responsive-transaction-list"

      # Verify URL includes page parameter
      assert_match(/page=2/, current_url)
    else
      skip "Pagination next link not found"
    end
  end

  private

    def create_multiple_transactions(count)
      # Helper method to create multiple transactions for pagination testing
      account = @user.family.accounts.first

      count.times do |i|
        Entry.create!(
          account: account,
          name: "Test Transaction #{i}",
          amount: -10.0,
          date: Date.current - i.days,
          entryable_type: "Transaction",
          entryable_attributes: {
            category_id: @user.family.categories.first.id
          }
        )
      end
    end
end
