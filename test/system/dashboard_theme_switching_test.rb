require "application_system_test_case"

class DashboardThemeSwitchingTest < ApplicationSystemTestCase
  setup do
    @user = users(:family_admin)
    sign_in @user
  end

  test "dashboard displays correctly in both themes" do
    visit root_path

    # Verify dashboard page loads
    assert_selector ".dashboard-page"

    # Check that theme-aware icon backgrounds are present
    assert_selector ".icon-bg-primary"

    # Verify no hardcoded colors are visible in light theme
    assert_no_selector ".bg-blue-100", visible: true
    assert_no_selector ".text-blue-600", visible: true

    # Switch to dark theme (assuming there's a theme toggle button)
    if page.has_selector?("[data-theme-toggle]", visible: true)
      click_button "[data-theme-toggle]"

      # Verify dark theme is applied
      assert_selector "[data-theme='dark']"

      # Verify theme-aware components still work
      assert_selector ".icon-bg-primary"

      # Verify no hardcoded light colors are visible in dark theme
      assert_no_selector ".bg-blue-100", visible: true
      assert_no_selector ".text-blue-600", visible: true
    end
  end

  test "dashboard components respect theme variables" do
    visit root_path

    # Check that CSS variables are being used
    icon_element = find(".icon-bg-primary", match: :first)

    # Verify the element has the correct class
    assert icon_element.has_css?(".icon-bg-primary")

    # Check for theme-aware styling
    computed_style = page.evaluate_script("getComputedStyle(document.querySelector('.icon-bg-primary'))")

    # Verify background color is not hardcoded
    refute_includes computed_style["background-color"], "rgb(219, 234, 254)" # bg-blue-100
  end
end
