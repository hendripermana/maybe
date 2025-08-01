require "application_system_test_case"

class ModernizedPagesUserFlowsTest < ApplicationSystemTestCase
  setup do
    @user = users(:family_admin)
    sign_in @user
  end

  # Test critical user flow: Dashboard overview to transaction details
  test "user can navigate from dashboard to transaction details" do
    visit root_path

    # Verify dashboard loads
    assert_selector ".dashboard-page", "Dashboard page should load"

    # Navigate to transactions page
    click_link "Transactions"
    assert_current_path transactions_path

    # Verify transactions page loads
    assert_selector ".transactions-page", "Transactions page should load"

    # View transaction details if available
    if has_selector?(".transaction-item")
      find(".transaction-item", match: :first).click

      # Verify transaction details are displayed
      assert_selector ".transaction-details", "Transaction details should be displayed"

      # Test editing transaction if available
      if has_selector?("a", text: "Edit")
        click_link "Edit"

        # Verify edit form is displayed
        assert_selector "form.transaction-form", "Transaction edit form should be displayed"

        # Test form submission (without actually submitting)
        assert_selector "button[type='submit']", "Form should have submit button"
      end
    end
  end

  # Test critical user flow: Dashboard overview to budget management
  test "user can navigate from dashboard to budget management" do
    visit root_path

    # Verify dashboard loads
    assert_selector ".dashboard-page", "Dashboard page should load"

    # Navigate to budgets page
    click_link "Budgets"
    assert_current_path budgets_path

    # Verify budgets page loads
    assert_selector ".budgets-page", "Budgets page should load"

    # View budget details if available
    if has_selector?(".budget-item")
      find(".budget-item", match: :first).click

      # Verify budget details are displayed
      assert_selector ".budget-details", "Budget details should be displayed"

      # Test editing budget if available
      if has_selector?("a", text: "Edit")
        click_link "Edit"

        # Verify edit form is displayed
        assert_selector "form.budget-form", "Budget edit form should be displayed"

        # Test form submission (without actually submitting)
        assert_selector "button[type='submit']", "Form should have submit button"
      end
    end
  end

  # Test critical user flow: Theme switching across pages
  test "theme switching works consistently across all pages" do
    # Define pages to test
    pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]

    # Start with light theme
    ensure_theme("light")

    # Visit each page and verify theme is consistent
    pages.each do |page|
      visit page[:path]

      # Verify page loads
      assert_selector "body", "#{page[:name]} page should load"

      # Verify light theme is applied
      assert_equal "light", current_theme, "Light theme should be applied on #{page[:name]} page"

      # Take screenshot for reference
      take_component_screenshot("#{page[:name].downcase}_light_theme")
    end

    # Switch to dark theme
    toggle_theme

    # Visit each page and verify theme is consistent
    pages.each do |page|
      visit page[:path]

      # Verify page loads
      assert_selector "body", "#{page[:name]} page should load"

      # Verify dark theme is applied
      assert_equal "dark", current_theme, "Dark theme should be applied on #{page[:name]} page"

      # Take screenshot for reference
      take_component_screenshot("#{page[:name].downcase}_dark_theme")
    end
  end

  # Test critical user flow: Search and filter transactions
  test "user can search and filter transactions" do
    visit transactions_path

    # Verify transactions page loads
    assert_selector ".transactions-page", "Transactions page should load"

    # Test search functionality if available
    if has_selector?("input[type='search']")
      # Enter search term
      fill_in "search", with: "Test"

      # Wait for search results
      sleep 0.5

      # Verify search results are displayed
      assert_selector ".transactions-list", "Search results should be displayed"
    end

    # Test filter functionality if available
    if has_selector?("button", text: "Filters")
      # Open filters
      click_button "Filters"

      # Verify filter options are displayed
      assert_selector ".filter-options", "Filter options should be displayed"

      # Select a filter option if available
      if has_selector?("input[type='checkbox']")
        first("input[type='checkbox']").click

        # Apply filters
        click_button "Apply"

        # Verify filtered results are displayed
        assert_selector ".transactions-list", "Filtered results should be displayed"
      end
    end
  end

  # Test critical user flow: Budget creation and management
  test "user can create and manage budgets" do
    visit budgets_path

    # Verify budgets page loads
    assert_selector ".budgets-page", "Budgets page should load"

    # Test budget creation if available
    if has_selector?("a", text: "New Budget")
      click_link "New Budget"

      # Verify budget creation form is displayed
      assert_selector "form#new_budget", "Budget creation form should be displayed"

      # Fill in form fields
      fill_in "budget[name]", with: "Test Budget"
      fill_in "budget[budgeted_spending]", with: "1000"
      fill_in "budget[expected_income]", with: "2000"

      # Test form submission (without actually submitting)
      assert_selector "button[type='submit']", "Form should have submit button"

      # Go back to budgets page
      visit budgets_path
    end

    # Test budget category management if available
    if has_selector?(".budget-item")
      find(".budget-item", match: :first).click

      # Verify budget details are displayed
      assert_selector ".budget-details", "Budget details should be displayed"

      # Test category management if available
      if has_selector?(".budget-category")
        # Verify category display
        assert_selector ".budget-category", "Budget categories should be displayed"

        # Test category editing if available
        if has_selector?(".budget-category-edit")
          find(".budget-category-edit", match: :first).click

          # Verify category edit form is displayed
          assert_selector ".budget-category-form", "Budget category edit form should be displayed"
        end
      end
    end
  end

  # Test critical user flow: Settings management
  test "user can manage settings and preferences" do
    visit settings_preferences_path

    # Verify settings page loads
    assert_selector ".settings-page", "Settings page should load"

    # Test theme preference if available
    if has_selector?("input[name='user[theme]'][value='dark']")
      choose "Dark"

      # Verify theme is applied
      assert_equal "dark", current_theme, "Dark theme should be applied"

      # Reset to light theme
      choose "Light"

      # Verify theme is applied
      assert_equal "light", current_theme, "Light theme should be applied"
    end

    # Test language preference if available
    if has_selector?("select[name='family[locale]']")
      select "English", from: "family[locale]"

      # Verify setting is saved
      assert_selector ".settings-saved-indicator", "Setting should be saved"
    end

    # Test accessibility preferences if available
    if has_selector?("input[name='user[high_contrast]']")
      # Toggle high contrast mode
      find("label", text: I18n.t("settings.preferences.show.enable_high_contrast")).click

      # Verify setting is saved
      assert_selector ".settings-saved-indicator", "Setting should be saved"

      # Toggle reduced motion
      find("label", text: I18n.t("settings.preferences.show.enable_reduced_motion")).click

      # Verify setting is saved
      assert_selector ".settings-saved-indicator", "Setting should be saved"
    end

    # Test navigation to other settings sections
    if has_selector?(".settings-navigation")
      # Find all settings navigation links
      settings_links = all(".settings-navigation a")

      # Visit each settings section
      settings_links.each do |link|
        link.click

        # Verify page loads
        assert_selector ".settings-page", "Settings page should load"

        # Verify section content is displayed
        assert_selector ".settings-content", "Settings content should be displayed"
      end
    end
  end
end
