require "application_system_test_case"

class BrowserCompatibilityTest < ApplicationSystemTestCase
  setup do
    @user = users(:default)
    login_as(@user)
  end

  test "theme switching works across browsers" do
    visit dashboard_path

    # Check initial theme
    initial_theme = page.find("html")["data-theme"]

    # Find and click theme toggle
    find("[data-action*='theme#toggle']").click

    # Verify theme changed
    new_theme = page.find("html")["data-theme"]
    assert_not_equal initial_theme, new_theme, "Theme should change when toggled"

    # Take screenshot for visual verification
    take_screenshot("theme-toggle-#{current_browser}")
  end

  test "dashboard layout is consistent" do
    visit dashboard_path

    # Check core layout elements
    assert_selector ".dashboard-grid"
    assert_selector ".chart-container", minimum: 1

    # Check for unwanted whitespace
    assert_no_selector ".py-6", visible: true

    # Take screenshot for visual verification
    take_screenshot("dashboard-layout-#{current_browser}")
  end

  test "form elements render consistently" do
    visit settings_path

    # Check form elements
    assert_selector "input[type='text']", minimum: 1
    assert_selector "button", minimum: 1

    # Focus an input and check focus styles
    find("input[type='text']").click

    # Take screenshot to verify focus styles
    take_screenshot("form-focus-#{current_browser}")
  end

  test "responsive design works across browsers" do
    # Test mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667)
    visit dashboard_path

    # Check mobile layout
    assert_selector ".dashboard-grid"

    # Take screenshot for mobile layout
    take_screenshot("mobile-layout-#{current_browser}")

    # Test desktop viewport
    page.driver.browser.manage.window.resize_to(1280, 800)
    visit dashboard_path

    # Check desktop layout
    assert_selector ".dashboard-grid"

    # Take screenshot for desktop layout
    take_screenshot("desktop-layout-#{current_browser}")
  end

  private

    def current_browser
      ENV["BROWSER"] || "chrome"
    end

    def take_screenshot(name)
      page.save_screenshot("tmp/screenshots/#{name}-#{Time.now.to_i}.png")
    end
end
