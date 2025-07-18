require "application_system_test_case"

class ResponsiveTransactionsKeyboardTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "transaction list can be fully navigated with keyboard" do
    visit transactions_path
    
    # Start from the beginning of the page
    page.execute_script("document.activeElement.blur()")
    
    # Press tab to start keyboard navigation
    page.send_keys(:tab)
    
    # Track elements we've successfully focused
    focused_elements = []
    
    # Try to tab through all interactive elements (limit to 30 to avoid infinite loop)
    30.times do
      # Get currently focused element
      focused_element = page.evaluate_script("document.activeElement")
      break if focused_elements.include?(focused_element)
      
      # Add to our list of focused elements
      focused_elements << focused_element
      
      # Press tab to move to next element
      page.send_keys(:tab)
    end
    
    # Verify we found interactive elements
    assert focused_elements.length > 3, "Should be able to tab through multiple elements"
    
    # Verify we can focus key interactive elements
    focused_types = page.evaluate_script(
      "Array.from(arguments[0]).map(el => el.tagName.toLowerCase() + (el.type ? ':' + el.type : ''))",
      focused_elements
    )
    
    # Check for essential interactive elements
    assert_includes focused_types, "input:search", "Should be able to focus search input"
    assert_includes focused_types, "button", "Should be able to focus buttons"
    
    if has_selector?(".responsive-transaction-item a")
      assert_includes focused_types, "a", "Should be able to focus transaction links"
    end
  end

  test "transaction filters can be operated with keyboard" do
    visit transactions_path
    
    # Find filter button
    filter_button = find(".responsive-transaction-filters button", text: "Filters")
    
    # Focus the button
    filter_button.send_keys(:tab)
    
    # Press enter to open dropdown
    page.send_keys(:enter)
    
    # Verify dropdown opens
    assert_selector ".responsive-transaction-filters [data-disclosure-target='content']", visible: true
    
    # Tab to first form control in dropdown
    page.send_keys(:tab)
    
    # Verify we can focus form controls in dropdown
    focused_element = page.evaluate_script("document.activeElement")
    focused_tag = page.evaluate_script("document.activeElement.tagName.toLowerCase()")
    
    assert ["input", "select", "button"].include?(focused_tag), 
           "Should be able to focus form controls in dropdown"
    
    # Press escape to close dropdown
    page.send_keys(:escape)
    
    # Verify dropdown closes
    assert_no_selector ".responsive-transaction-filters [data-disclosure-target='content']", visible: true
  end

  test "transaction bulk actions can be operated with keyboard" do
    visit transactions_path
    
    # Skip if no transactions
    skip "No transactions found" unless has_selector?(".responsive-transaction-item")
    
    # Find first checkbox
    checkbox = find(".responsive-transaction-item input[type='checkbox']", match: :first)
    
    # Focus and check the checkbox
    checkbox.send_keys(:tab)
    page.send_keys(:space)
    
    # Verify checkbox is checked
    assert checkbox.checked?, "Checkbox should be checked after pressing space"
    
    # Verify bulk action bar appears
    assert_selector "[data-bulk-select-target='bar']", visible: true
    
    # Tab to bulk update button
    update_button_found = false
    10.times do # Limit to avoid infinite loop
      page.send_keys(:tab)
      
      # Check if we've focused the update button
      focused_text = page.evaluate_script("document.activeElement.textContent")
      if focused_text&.include?("Update")
        update_button_found = true
        break
      end
    end
    
    assert update_button_found, "Should be able to focus bulk update button"
    
    # Press enter to open bulk update form
    page.send_keys(:enter)
    
    # Verify bulk update form appears
    assert_selector ".transaction-bulk-update-container", visible: true
    
    # Tab to cancel button
    cancel_button_found = false
    20.times do # Limit to avoid infinite loop
      page.send_keys(:tab)
      
      # Check if we've focused the cancel button
      focused_text = page.evaluate_script("document.activeElement.textContent")
      if focused_text&.include?("Cancel")
        cancel_button_found = true
        break
      end
    end
    
    assert cancel_button_found, "Should be able to focus cancel button"
    
    # Press enter to close form
    page.send_keys(:enter)
    
    # Verify form closes
    assert_no_selector ".transaction-bulk-update-container", visible: true
  end

  test "transaction form can be operated with keyboard" do
    visit transactions_path
    
    # Find new transaction button
    new_button = find("a", text: /new transaction/i, match: :first)
    
    # Focus and click the button
    new_button.send_keys(:tab)
    page.send_keys(:enter)
    
    # Verify transaction form appears
    assert_selector ".transaction-form-container", visible: true
    
    # Tab to first form field
    page.send_keys(:tab)
    
    # Verify we can focus form fields
    focused_element = page.evaluate_script("document.activeElement")
    focused_tag = page.evaluate_script("document.activeElement.tagName.toLowerCase()")
    
    assert ["input", "select", "textarea"].include?(focused_tag), 
           "Should be able to focus form fields"
    
    # Fill out form using keyboard
    if focused_tag == "input"
      page.send_keys("Test Transaction")
    end
    
    # Tab to next field
    page.send_keys(:tab)
    
    # Continue tabbing through form
    10.times do
      page.send_keys(:tab)
    end
    
    # Verify we can reach submit button
    submit_button_found = false
    10.times do # Limit to avoid infinite loop
      focused_type = page.evaluate_script("document.activeElement.type")
      focused_text = page.evaluate_script("document.activeElement.textContent")
      
      if focused_type == "submit" || (focused_text && focused_text.include?("Create Transaction"))
        submit_button_found = true
        break
      end
      
      page.send_keys(:tab)
    end
    
    assert submit_button_found, "Should be able to focus submit button"
    
    # Press escape to close form
    page.send_keys(:escape)
    
    # Verify we're back at transactions list
    assert_selector ".responsive-transaction-container", visible: true
  end

  test "transaction pagination can be operated with keyboard" do
    # Create enough transactions to trigger pagination
    create_multiple_transactions(30)
    
    visit transactions_path
    
    # Verify pagination appears
    assert_selector "nav[aria-label='Pagination']"
    
    # Tab to pagination
    pagination_link_found = false
    30.times do # Limit to avoid infinite loop
      page.send_keys(:tab)
      
      # Check if we've focused a pagination link
      focused_element = page.evaluate_script("document.activeElement")
      focused_parent = page.evaluate_script(
        "document.activeElement.closest('nav[aria-label=\"Pagination\"]')"
      )
      
      if focused_parent
        pagination_link_found = true
        break
      end
    end
    
    assert pagination_link_found, "Should be able to focus pagination links"
    
    # Press enter to navigate
    page.send_keys(:enter)
    
    # Verify page changes
    assert_selector ".responsive-transaction-list"
  end

  test "transaction list has proper focus indicators" do
    visit transactions_path
    
    # Find interactive elements
    interactive_elements = [
      ".responsive-transaction-filters button",
      ".responsive-transaction-filters input",
      ".responsive-transaction-item a",
      ".responsive-transaction-item input[type='checkbox']",
      "nav[aria-label='Pagination'] a"
    ]
    
    # Test each type of element
    interactive_elements.each do |selector|
      next unless has_selector?(selector)
      
      # Find first matching element
      element = find(selector, match: :first)
      
      # Focus the element
      element.send_keys(:tab)
      
      # Verify it's focused
      focused_element = page.evaluate_script("document.activeElement")
      assert_equal element.native, focused_element, "Element should be focusable"
      
      # Check for visible focus indicator
      focus_styles = page.evaluate_script(
        "window.getComputedStyle(document.activeElement)"
      )
      
      has_focus_indicator = focus_styles["outline"] != "none" || 
                           focus_styles["boxShadow"] != "none" ||
                           focus_styles["border"].include?("rgb") # Check for colored border
      
      assert has_focus_indicator, "Element should have visible focus indicator"
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