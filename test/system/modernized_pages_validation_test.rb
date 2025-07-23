require "application_system_test_case"

class ModernizedPagesValidationTest < ApplicationSystemTestCase
  setup do
    @user = users(:family_admin)
    sign_in @user
  end

  # Test all modernized pages for theme consistency
  test "all modernized pages display correctly in both themes" do
    # Define all modernized pages to test
    modernized_pages = [
      { path: root_path, name: "Dashboard", selector: ".dashboard-page" },
      { path: transactions_path, name: "Transactions", selector: ".transactions-page" },
      { path: budgets_path, name: "Budgets", selector: ".budgets-page" },
      { path: settings_preferences_path, name: "Settings", selector: ".settings-page" }
    ]
    
    # Test each page in both themes
    modernized_pages.each do |page|
      visit page[:path]
      
      # Verify page loads with correct structure
      assert_selector page[:selector], "#{page[:name]} page should load with correct structure"
      
      # Test in light theme
      ensure_theme("light")
      
      # Verify no hardcoded colors in light theme
      assert_no_hardcoded_colors("body")
      
      # Take screenshot for reference
      take_component_screenshot("#{page[:name].downcase}_light")
      
      # Test in dark theme
      ensure_theme("dark")
      
      # Verify no hardcoded colors in dark theme
      assert_no_hardcoded_colors("body")
      
      # Take screenshot for reference
      take_component_screenshot("#{page[:name].downcase}_dark")
    end
  end
  
  # Test all modernized pages for responsive behavior
  test "all modernized pages are responsive across device sizes" do
    # Define all modernized pages to test
    modernized_pages = [
      { path: root_path, name: "Dashboard", selector: ".dashboard-page" },
      { path: transactions_path, name: "Transactions", selector: ".transactions-page" },
      { path: budgets_path, name: "Budgets", selector: ".budgets-page" },
      { path: settings_preferences_path, name: "Settings", selector: ".settings-page" }
    ]
    
    # Test each page at different viewport sizes
    modernized_pages.each do |page|
      # Test at different viewport sizes
      UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports].each do |viewport_name, dimensions|
        with_viewport(*dimensions) do
          visit page[:path]
          
          # Verify page loads with correct structure
          assert_selector page[:selector], "#{page[:name]} page should load with correct structure on #{viewport_name}"
          
          # Take screenshot for reference
          take_component_screenshot("#{page[:name].downcase}_#{viewport_name}")
          
          # Check for responsive layout adjustments
          case viewport_name
          when :mobile
            # Mobile layout checks
            assert_no_selector ".hidden-mobile", visible: true
            
          when :tablet
            # Tablet layout checks
            assert_selector ".hidden-mobile", visible: true
            
          when :desktop
            # Desktop layout checks
            assert_selector ".hidden-mobile", visible: true
          end
        end
      end
    end
  end
  
  # Test all modernized pages for accessibility compliance
  test "all modernized pages meet accessibility standards" do
    # Define all modernized pages to test
    modernized_pages = [
      { path: root_path, name: "Dashboard", selector: ".dashboard-page" },
      { path: transactions_path, name: "Transactions", selector: ".transactions-page" },
      { path: budgets_path, name: "Budgets", selector: ".budgets-page" },
      { path: settings_preferences_path, name: "Settings", selector: ".settings-page" }
    ]
    
    # Test each page for accessibility
    modernized_pages.each do |page|
      visit page[:path]
      
      # Verify page loads with correct structure
      assert_selector page[:selector], "#{page[:name]} page should load with correct structure"
      
      # Check for proper heading hierarchy
      assert_proper_heading_hierarchy
      
      # Check for proper form labels
      assert_proper_form_labels
      
      # Check for keyboard navigation
      tab_through_form(10)
      
      # Check for screen reader accessibility
      assert_screen_reader_accessible
    end
  end
  
  # Test functionality preservation for Dashboard page
  test "dashboard page preserves all functionality after modernization" do
    visit root_path
    
    # Verify key dashboard components are present
    assert_selector ".dashboard-summary", "Dashboard summary should be present"
    assert_selector ".dashboard-chart", "Dashboard chart should be present"
    
    # Verify interactive elements work
    if has_selector?(".dashboard-chart-toggle")
      find(".dashboard-chart-toggle").click
      assert_selector ".dashboard-chart-expanded", "Chart toggle should work"
    end
    
    # Verify data is displayed correctly
    assert_selector ".dashboard-balance", "Balance information should be displayed"
  end
  
  # Test functionality preservation for Transactions page
  test "transactions page preserves all functionality after modernization" do
    visit transactions_path
    
    # Verify key transaction components are present
    assert_selector ".transactions-list", "Transaction list should be present"
    assert_selector ".transaction-filters", "Transaction filters should be present"
    
    # Verify search functionality works
    if has_selector?("input[type='search']")
      fill_in "search", with: "Test"
      assert_selector ".transactions-list", "Transaction list should update after search"
    end
    
    # Verify transaction details can be viewed
    if has_selector?(".transaction-item")
      find(".transaction-item", match: :first).click
      assert_selector ".transaction-details", "Transaction details should be viewable"
    end
  end
  
  # Test functionality preservation for Budgets page
  test "budgets page preserves all functionality after modernization" do
    visit budgets_path
    
    # Verify key budget components are present
    assert_selector ".budget-summary", "Budget summary should be present"
    assert_selector ".budget-categories", "Budget categories should be present"
    
    # Verify budget creation works
    if has_selector?("a", text: "New Budget")
      click_link "New Budget"
      assert_selector "form#new_budget", "Budget creation form should be accessible"
      # Go back to budgets page
      visit budgets_path
    end
    
    # Verify budget details can be viewed
    if has_selector?(".budget-item")
      find(".budget-item", match: :first).click
      assert_selector ".budget-details", "Budget details should be viewable"
    end
  end
  
  # Test functionality preservation for Settings page
  test "settings page preserves all functionality after modernization" do
    visit settings_preferences_path
    
    # Verify key settings components are present
    assert_selector ".settings-navigation", "Settings navigation should be present"
    assert_selector ".settings-form", "Settings form should be present"
    
    # Verify theme switching works
    if has_selector?("input[name='user[theme]'][value='dark']")
      choose "Dark"
      assert_equal "dark", current_theme, "Theme switching should work"
    end
    
    # Verify settings can be saved
    if has_selector?("select[name='family[locale]']")
      select "English", from: "family[locale]"
      assert_selector ".settings-saved-indicator", "Settings should be savable"
    end
  end
  
  # Test critical user flows across modernized pages
  test "critical user flows work across modernized pages" do
    # Test flow: View dashboard -> View transaction -> Edit transaction
    visit root_path
    
    # Navigate to transactions
    click_link "Transactions"
    assert_current_path transactions_path
    
    # View a transaction if available
    if has_selector?(".transaction-item")
      find(".transaction-item", match: :first).click
      assert_selector ".transaction-details", "Transaction details should be viewable"
      
      # Edit transaction if possible
      if has_selector?("a", text: "Edit")
        click_link "Edit"
        assert_selector "form.transaction-form", "Transaction edit form should be accessible"
      end
    end
    
    # Test flow: View dashboard -> View budget -> Edit budget
    visit root_path
    
    # Navigate to budgets
    click_link "Budgets"
    assert_current_path budgets_path
    
    # View a budget if available
    if has_selector?(".budget-item")
      find(".budget-item", match: :first).click
      assert_selector ".budget-details", "Budget details should be viewable"
      
      # Edit budget if possible
      if has_selector?("a", text: "Edit")
        click_link "Edit"
        assert_selector "form.budget-form", "Budget edit form should be accessible"
      end
    end
    
    # Test flow: View dashboard -> Access settings -> Change theme
    visit root_path
    
    # Navigate to settings
    open_settings_from_sidebar
    assert_current_path settings_preferences_path
    
    # Change theme
    if has_selector?("input[name='user[theme]'][value='dark']")
      choose "Dark"
      assert_equal "dark", current_theme, "Theme switching should work"
    end
  end
end