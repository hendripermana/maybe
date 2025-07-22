require "application_system_test_case"

class CrossBrowserUITest < ApplicationSystemTestCase
  # This test class is designed to be run in multiple browsers
  # Run with: BROWSER=chrome|firefox|safari|edge rails test:system test/system/cross_browser_ui_test.rb
  
  setup do
    @user = users(:default)
    login_as(@user)
  end

  test "dashboard renders correctly" do
    visit dashboard_path
    
    # Test core layout elements
    assert_selector "h1", text: "Dashboard"
    assert_selector ".dashboard-grid"
    
    # Test theme switching
    if has_css?("#theme-toggle")
      initial_theme = find("html")["data-theme"]
      find("#theme-toggle").click
      new_theme = find("html")["data-theme"]
      assert_not_equal initial_theme, new_theme, "Theme should change when toggled"
      
      # Switch back to original theme
      find("#theme-toggle").click
    end
    
    # Test chart containers
    assert_selector ".chart-container", minimum: 1
    
    # Take screenshot for visual comparison
    take_screenshot("dashboard-#{current_browser}")
  end
  
  test "transactions page renders correctly" do
    visit transactions_path
    
    # Test core layout elements
    assert_selector "h1", text: /Transactions/i
    
    # Test transaction list
    assert_selector ".transaction-item", minimum: 1, wait: 5
    
    # Test filtering components if present
    if has_css?(".filter-component")
      find(".filter-component").click
      assert_selector ".filter-dropdown", visible: true
    end
    
    # Take screenshot for visual comparison
    take_screenshot("transactions-#{current_browser}")
  end
  
  test "budgets page renders correctly" do
    visit budgets_path
    
    # Test core layout elements
    assert_selector "h1", text: /Budgets/i
    
    # Test budget components
    assert_selector ".budget-card", minimum: 1, wait: 5
    
    # Test progress bars if present
    assert_selector ".progress-bar", minimum: 1
    
    # Take screenshot for visual comparison
    take_screenshot("budgets-#{current_browser}")
  end
  
  test "settings page renders correctly" do
    visit settings_path
    
    # Test core layout elements
    assert_selector "h1", text: /Settings/i
    
    # Test settings navigation
    assert_selector ".settings-nav", minimum: 1
    
    # Test form elements
    assert_selector "form", minimum: 1
    
    # Test theme preferences if present
    if has_css?(".theme-preferences")
      find(".theme-preferences").click
      assert_selector ".theme-options", visible: true
    end
    
    # Take screenshot for visual comparison
    take_screenshot("settings-#{current_browser}")
  end
  
  test "component styling consistency" do
    visit ui_path # Assuming there's a UI showcase page
    
    # Test button variants
    assert_selector ".btn-modern-primary", minimum: 1
    assert_selector ".btn-modern-secondary", minimum: 1
    
    # Test form inputs
    assert_selector "input[type='text']", minimum: 1
    
    # Test cards
    assert_selector ".card", minimum: 1
    
    # Test modals if present
    if has_css?("[data-controller='dialog']")
      find("[data-action='dialog#open']").click
      assert_selector ".dialog", visible: true
      find("[data-action='dialog#close']").click
    end
    
    # Take screenshot for visual comparison
    take_screenshot("components-#{current_browser}")
  end
  
  private
  
  def current_browser
    ENV["BROWSER"] || "chrome"
  end
  
  def take_screenshot(name)
    page.save_screenshot("tmp/screenshots/#{name}-#{Time.now.to_i}.png")
  end
end