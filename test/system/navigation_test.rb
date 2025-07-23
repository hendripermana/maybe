# frozen_string_literal: true

require "application_system_test_case"

class NavigationTest < ApplicationSystemTestCase
  setup do
    @user = users(:john)
    login_as(@user)
  end

  test "desktop navigation shows correct active states" do
    visit root_path
    
    # Home should be active
    assert_selector ".sidebar-modern a[aria-current='page']", text: "Home"
    
    # Navigate to transactions
    click_on "Transactions"
    assert_current_path transactions_path
    assert_selector ".sidebar-modern a[aria-current='page']", text: "Transactions"
    
    # Navigate to budgets
    click_on "Budgets"
    assert_current_path budgets_path
    assert_selector ".sidebar-modern a[aria-current='page']", text: "Budgets"
  end

  test "mobile navigation shows correct active states" do
    # Set viewport to mobile size
    page.driver.browser.manage.window.resize_to(375, 667)
    
    visit root_path
    
    # Home should be active in bottom nav
    assert_selector "nav a[aria-current='page']", text: "Home"
    
    # Navigate to transactions
    within "nav" do
      click_on "Transactions"
    end
    assert_current_path transactions_path
    assert_selector "nav a[aria-current='page']", text: "Transactions"
    
    # Navigate to budgets
    within "nav" do
      click_on "Budgets"
    end
    assert_current_path budgets_path
    assert_selector "nav a[aria-current='page']", text: "Budgets"
  end

  test "breadcrumbs show correct path" do
    visit transactions_path
    
    # Should show transactions breadcrumb
    assert_selector "nav[aria-label='Breadcrumb'] span[aria-current='page']", text: "Transactions"
    
    # Navigate to a specific transaction (assuming transaction with ID 1 exists)
    visit transaction_path(transactions(:one))
    
    # Should show transaction details breadcrumb
    assert_selector "nav[aria-label='Breadcrumb'] a", text: "Transactions"
    assert_selector "nav[aria-label='Breadcrumb'] span[aria-current='page']", text: /Details|Transaction/
  end

  test "keyboard navigation works" do
    visit root_path
    
    # Tab to focus on first navigation item
    find("body").send_keys(:tab)
    
    # Press down arrow to navigate to next item
    find("body").send_keys(:arrow_down)
    
    # Press enter to navigate to that page
    find("body").send_keys(:return)
    
    # Should navigate to transactions
    assert_current_path transactions_path
  end
end