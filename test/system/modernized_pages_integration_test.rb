require "application_system_test_case"

class ModernizedPagesIntegrationTest < ApplicationSystemTestCase
  setup do
    @user = users(:family_admin)
    sign_in @user
  end

  # Test complete user workflow across multiple pages
  test "complete user workflow from dashboard to transactions to budget" do
    visit root_path
    
    # Verify dashboard loads
    assert_selector ".dashboard-page", "Dashboard page should load"
    
    # Check theme consistency
    theme = current_theme
    assert ["light", "dark"].include?(theme), "Theme should be either light or dark"
    
    # Navigate to transactions page
    click_link "Transactions"
    assert_current_path transactions_path
    
    # Verify theme consistency is maintained
    assert_equal theme, current_theme, "Theme should be consistent when navigating between pages"
    
    # Verify transactions page loads
    assert_selector ".transactions-page", "Transactions page should load"
    
    # Create a new transaction if possible
    if has_selector?("a", text: "New Transaction")
      click_link "New Transaction"
      
      # Verify new transaction form loads
      assert_selector "form.transaction-form", "New transaction form should load"
      
      # Fill in transaction details
      fill_in "transaction[description]", with: "Integration Test Transaction"
      fill_in "transaction[amount]", with: "100"
      
      # Select a category if available
      if has_selector?("select#transaction_category_id")
        select_first_option("transaction_category_id")
      end
      
      # Select an account if available
      if has_selector?("select#transaction_account_id")
        select_first_option("transaction_account_id")
      end
      
      # Submit the form
      click_button "Save"
      
      # Verify transaction was created
      assert_selector ".flash-success", "Transaction should be created successfully"
      assert_selector ".transaction-item", text: "Integration Test Transaction", "New transaction should appear in the list"
    end
    
    # Navigate to budgets page
    click_link "Budgets"
    assert_current_path budgets_path
    
    # Verify theme consistency is maintained
    assert_equal theme, current_theme, "Theme should be consistent when navigating between pages"
    
    # Verify budgets page loads
    assert_selector ".budgets-page", "Budgets page should load"
    
    # Create a new budget if possible
    if has_selector?("a", text: "New Budget")
      click_link "New Budget"
      
      # Verify new budget form loads
      assert_selector "form#new_budget", "New budget form should load"
      
      # Fill in budget details
      fill_in "budget[name]", with: "Integration Test Budget"
      fill_in "budget[budgeted_spending]", with: "1000"
      
      # Submit the form
      click_button "Save"
      
      # Verify budget was created
      assert_selector ".flash-success", "Budget should be created successfully"
      assert_selector ".budget-item", text: "Integration Test Budget", "New budget should appear in the list"
    end
    
    # Navigate to settings
    open_settings_from_sidebar
    assert_current_path settings_preferences_path
    
    # Verify theme consistency is maintained
    assert_equal theme, current_theme, "Theme should be consistent when navigating between pages"
    
    # Verify settings page loads
    assert_selector ".settings-page", "Settings page should load"
    
    # Toggle theme
    toggle_theme
    
    # Verify theme has changed
    new_theme = current_theme
    assert_not_equal theme, new_theme, "Theme should change when toggled"
    
    # Navigate back to dashboard
    click_link "Dashboard"
    assert_current_path root_path
    
    # Verify theme change persists
    assert_equal new_theme, current_theme, "Theme change should persist when navigating between pages"
  end
  
  # Test component integration across pages
  test "components maintain consistency across all pages" do
    # Define pages to test
    pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]
    
    # Test each page for component consistency
    pages.each do |page|
      visit page[:path]
      
      # Verify page loads
      assert_selector "body", "#{page[:name]} page should load"
      
      # Check for consistent header
      assert_selector "header", "Header should be present on #{page[:name]} page"
      
      # Check for consistent navigation
      assert_selector "nav", "Navigation should be present on #{page[:name]} page"
      
      # Check for consistent footer
      assert_selector "footer", "Footer should be present on #{page[:name]} page"
      
      # Check for consistent button styling
      if has_selector?("button")
        button_classes = find("button", match: :first)[:class]
        assert button_classes.include?("btn-modern"), "Buttons should use modern styling on #{page[:name]} page"
      end
      
      # Check for consistent card styling
      if has_selector?(".card")
        card_classes = find(".card", match: :first)[:class]
        assert card_classes.include?("card-modern"), "Cards should use modern styling on #{page[:name]} page"
      end
      
      # Check for consistent form styling
      if has_selector?("form")
        form_inputs = all("form input[type='text'], form input[type='email'], form select")
        form_inputs.each do |input|
          assert input[:class].include?("input-modern"), "Form inputs should use modern styling on #{page[:name]} page"
        end
      end
    end
  end
  
  # Test form validation consistency
  test "form validation is consistent across all forms" do
    # Test transaction form validation
    visit new_transaction_path
    
    # Submit empty form
    click_button "Save"
    
    # Verify validation errors are displayed consistently
    assert_selector ".form-error", "Validation errors should be displayed"
    
    # Test budget form validation
    visit new_budget_path
    
    # Submit empty form
    click_button "Save"
    
    # Verify validation errors are displayed consistently
    assert_selector ".form-error", "Validation errors should be displayed"
    
    # Test settings form validation
    visit settings_preferences_path
    
    # Find a required field and clear it
    if has_selector?("input[required]")
      input = find("input[required]", match: :first)
      input.fill_in with: ""
      
      # Submit form
      click_button "Save"
      
      # Verify validation errors are displayed consistently
      assert_selector ".form-error", "Validation errors should be displayed"
    end
  end
  
  # Test modal dialog integration
  test "modal dialogs work consistently across all pages" do
    # Test dashboard modals
    visit root_path
    
    # Open a modal if available
    if has_selector?("[data-modal-trigger]")
      find("[data-modal-trigger]", match: :first).click
      
      # Verify modal opens
      assert_selector ".modal-dialog", "Modal should open"
      
      # Verify modal can be closed
      find(".modal-close").click
      assert_no_selector ".modal-dialog", "Modal should close"
    end
    
    # Test transaction modals
    visit transactions_path
    
    # Open a modal if available
    if has_selector?("[data-modal-trigger]")
      find("[data-modal-trigger]", match: :first).click
      
      # Verify modal opens
      assert_selector ".modal-dialog", "Modal should open"
      
      # Verify modal can be closed
      find(".modal-close").click
      assert_no_selector ".modal-dialog", "Modal should close"
    end
    
    # Test budget modals
    visit budgets_path
    
    # Open a modal if available
    if has_selector?("[data-modal-trigger]")
      find("[data-modal-trigger]", match: :first).click
      
      # Verify modal opens
      assert_selector ".modal-dialog", "Modal should open"
      
      # Verify modal can be closed
      find(".modal-close").click
      assert_no_selector ".modal-dialog", "Modal should close"
    end
  end
  
  # Test theme switching across all components
  test "theme switching affects all components consistently" do
    visit root_path
    
    # Get all component types to test
    component_types = [
      { selector: "button", name: "Button" },
      { selector: ".card", name: "Card" },
      { selector: "input[type='text']", name: "Text Input" },
      { selector: "select", name: "Select" },
      { selector: ".modal-dialog", name: "Modal", trigger: "[data-modal-trigger]" },
      { selector: ".alert", name: "Alert" }
    ]
    
    # Start with light theme
    ensure_theme("light")
    
    # Capture light theme styles
    light_theme_styles = {}
    component_types.each do |component|
      next unless has_selector?(component[:selector]) || (component[:trigger] && has_selector?(component[:trigger]))
      
      # Trigger modal if needed
      if component[:trigger] && has_selector?(component[:trigger])
        find(component[:trigger], match: :first).click
      end
      
      if has_selector?(component[:selector])
        element = find(component[:selector], match: :first)
        light_theme_styles[component[:name]] = get_element_styles(element)
      end
      
      # Close modal if opened
      if component[:trigger] && has_selector?(".modal-close")
        find(".modal-close").click
      end
    end
    
    # Switch to dark theme
    toggle_theme
    
    # Capture dark theme styles
    dark_theme_styles = {}
    component_types.each do |component|
      next unless has_selector?(component[:selector]) || (component[:trigger] && has_selector?(component[:trigger]))
      
      # Trigger modal if needed
      if component[:trigger] && has_selector?(component[:trigger])
        find(component[:trigger], match: :first).click
      end
      
      if has_selector?(component[:selector])
        element = find(component[:selector], match: :first)
        dark_theme_styles[component[:name]] = get_element_styles(element)
      end
      
      # Close modal if opened
      if component[:trigger] && has_selector?(".modal-close")
        find(".modal-close").click
      end
    end
    
    # Verify styles changed between themes
    component_types.each do |component|
      next unless light_theme_styles[component[:name]] && dark_theme_styles[component[:name]]
      
      # Check that at least background or text color changed
      assert light_theme_styles[component[:name]][:background_color] != dark_theme_styles[component[:name]][:background_color] ||
             light_theme_styles[component[:name]][:color] != dark_theme_styles[component[:name]][:color],
             "#{component[:name]} should have different styling between themes"
    end
  end
  
  # Test accessibility across all pages
  test "accessibility features are consistent across all pages" do
    # Define pages to test
    pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]
    
    # Test each page for accessibility consistency
    pages.each do |page|
      visit page[:path]
      
      # Verify page loads
      assert_selector "body", "#{page[:name]} page should load"
      
      # Check for proper heading hierarchy
      assert_proper_heading_hierarchy
      
      # Check for proper ARIA landmarks
      assert_selector "[role='main'], main", "Page should have main landmark"
      assert_selector "header, [role='banner']", "Page should have header landmark"
      assert_selector "nav, [role='navigation']", "Page should have navigation landmark"
      
      # Check for skip link
      assert has_selector?("a[href='#main-content']", visible: false) || 
             has_selector?("a[href='#content']", visible: false),
             "Page should have skip link for accessibility"
      
      # Check for proper form labels
      assert_proper_form_labels
      
      # Check for keyboard navigation
      tab_through_form(5)
    end
  end
  
  # Test performance across all pages
  test "performance is consistent across all pages" do
    # Define pages to test
    pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]
    
    # Test each page for performance
    pages.each do |page|
      # Measure page load time
      start_time = Time.current
      visit page[:path]
      end_time = Time.current
      
      # Verify page loads within acceptable time (2 seconds)
      load_time = (end_time - start_time).to_f
      assert load_time < 2.0, "#{page[:name]} page should load within 2 seconds (took #{load_time.round(2)}s)"
      
      # Check for layout shifts
      assert_no_layout_shift
      
      # Measure theme switching performance
      start_time = Time.current
      toggle_theme
      end_time = Time.current
      
      # Verify theme switching is performant (under 0.5 seconds)
      theme_switch_time = (end_time - start_time).to_f
      assert theme_switch_time < 0.5, "Theme switching should be performant on #{page[:name]} page (took #{theme_switch_time.round(2)}s)"
    end
  end
  
  private
  
  def select_first_option(select_id)
    # Select the first option in a dropdown
    select = find_by_id(select_id)
    option = select.find("option:not([value=''])") rescue select.find("option")
    select.select option.text
  end
  
  def get_element_styles(element)
    # Get computed styles for an element
    {
      background_color: page.evaluate_script("window.getComputedStyle(arguments[0]).backgroundColor", element.native),
      color: page.evaluate_script("window.getComputedStyle(arguments[0]).color", element.native),
      border_color: page.evaluate_script("window.getComputedStyle(arguments[0]).borderColor", element.native)
    }
  end
  
  def assert_no_layout_shift
    # Capture initial positions of key elements
    initial_positions = {}
    
    all(".card, .container, main > *", visible: true).each_with_index do |element, index|
      rect = page.evaluate_script("arguments[0].getBoundingClientRect()", element.native)
      initial_positions["element-#{index}"] = { top: rect["top"], left: rect["left"] }
    end
    
    # Trigger potential layout shifts (e.g., by loading images or expanding elements)
    page.execute_script("window.dispatchEvent(new Event('resize'))")
    sleep 0.5
    
    # Check if elements moved
    all(".card, .container, main > *", visible: true).each_with_index do |element, index|
      next unless initial_positions["element-#{index}"]
      
      rect = page.evaluate_script("arguments[0].getBoundingClientRect()", element.native)
      
      # Allow small tolerance for rounding errors (2 pixels)
      assert (rect["top"] - initial_positions["element-#{index}"][:top]).abs < 2,
             "Element should not shift vertically"
      
      assert (rect["left"] - initial_positions["element-#{index}"][:left]).abs < 2,
             "Element should not shift horizontally"
    end
  end
  
  def tab_through_form(max_tabs)
    # Tab through form elements to test keyboard navigation
    element = find("body")
    
    max_tabs.times do
      element.send_keys(:tab)
      
      # Verify focus is visible
      assert_selector ":focus", count: 1, message: "Focus should be visible"
      
      # Get focused element
      focused_element = find(:focus)
      
      # Check for visible focus indicator
      styles = page.evaluate_script("window.getComputedStyle(arguments[0])", focused_element.native)
      
      has_outline = styles["outline"] != "none" && styles["outline-width"] != "0px"
      has_box_shadow = styles["boxShadow"] != "none"
      has_border = styles["border"] != "none" && styles["borderWidth"] != "0px"
      
      assert(has_outline || has_box_shadow || has_border,
             "Element should have visible focus indicator")
    end
  end
end