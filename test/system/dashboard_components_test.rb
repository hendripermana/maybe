require "application_system_test_case"

class DashboardComponentsTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "dashboard card components render correctly" do
    visit root_path

    # Verify all dashboard cards are present
    assert_selector ".dashboard-card", minimum: 3

    # Test card components in both themes
    test_both_themes do
      # Check that cards use theme variables
      cards = all(".dashboard-card")
      cards.each do |card|
        assert_no_hardcoded_colors(card)
        assert card[:class].include?("bg-card"), "Card should use bg-card class for theme awareness"
      end
    end
  end

  test "dashboard chart components render correctly" do
    visit root_path

    # Verify chart containers are present
    assert_selector ".chart-container", minimum: 1

    # Test chart containers in both themes
    test_both_themes do
      charts = all(".chart-container")
      charts.each do |chart|
        assert_no_hardcoded_colors(chart)
      end

      # Test Sankey chart specifically if it exists
      if has_selector?("#sankey-chart")
        assert_selector "#sankey-chart .node rect"
        assert_selector "#sankey-chart .link"
      end
    end
  end

  test "dashboard interactive components are accessible" do
    visit root_path

    # Test buttons
    buttons = all("button, .btn-modern-primary, .btn-modern-secondary")
    buttons.each do |button|
      assert_accessible_name(button)
      assert_keyboard_navigable(button)
    end

    # Test interactive chart elements if present
    if has_selector?(".chart-interactive")
      interactive_elements = all(".chart-interactive")
      interactive_elements.each do |element|
        assert_accessible_name(element)
      end
    end
  end

  test "dashboard layout is responsive" do
    # Test on mobile viewport
    with_viewport(*UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports][:mobile]) do
      visit root_path
      assert_selector ".dashboard-page"

      # Verify mobile layout adjustments
      assert_no_selector ".dashboard-sidebar", visible: true
      assert_selector ".mobile-menu-button", visible: true
    end

    # Test on tablet viewport
    with_viewport(*UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports][:tablet]) do
      visit root_path
      assert_selector ".dashboard-page"
    end

    # Test on desktop viewport
    with_viewport(*UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports][:desktop]) do
      visit root_path
      assert_selector ".dashboard-page"

      # Verify desktop layout
      assert_selector ".dashboard-sidebar", visible: true
      assert_no_selector ".mobile-menu-button", visible: true
    end
  end

  test "dashboard components meet accessibility standards" do
    visit root_path

    # Test heading hierarchy
    assert_proper_heading_hierarchy

    # Test color contrast
    dashboard_elements = [
      ".dashboard-card",
      ".chart-container",
      ".dashboard-header",
      ".dashboard-summary"
    ]

    dashboard_elements.each do |selector|
      if has_selector?(selector)
        assert_sufficient_color_contrast(selector)
      end
    end

    # Test keyboard navigation
    interactive_elements = all("button, a, [role='button'], [tabindex='0']")
    interactive_elements.each do |element|
      assert_keyboard_navigable(element)
    end

    # Test form elements if present
    if has_selector?("form")
      assert_proper_form_labels
    end

    # Test for ARIA attributes
    aria_elements = all("[aria-label], [aria-labelledby], [aria-describedby]")
    aria_elements.each do |element|
      assert_proper_aria_attributes(element)
    end

    # Run comprehensive accessibility check
    assert_no_accessibility_violations
  end

  test "dashboard theme switching works correctly" do
    visit root_path

    # Test initial theme
    initial_theme = current_theme
    assert [ "light", "dark" ].include?(initial_theme), "Initial theme should be light or dark"

    # Toggle theme
    toggle_theme

    # Verify theme changed
    new_theme = current_theme
    assert_not_equal initial_theme, new_theme, "Theme should change after toggle"

    # Verify theme-aware components update correctly
    theme_aware_elements = [
      ".dashboard-card",
      ".chart-container",
      ".dashboard-header",
      ".btn-modern-primary"
    ]

    theme_aware_elements.each do |selector|
      if has_selector?(selector)
        assert_theme_aware_colors(selector)
      end
    end

    # Test CSS variables are applied
    UiTestingConfig::THEME_CONFIG[:css_variables].each do |variable|
      assert_css_variable_defined(variable)
    end
  end

  test "dashboard fullscreen modal works in both themes" do
    visit root_path

    # Find fullscreen button if it exists
    if has_selector?("[data-action*='fullscreen']")
      # Test in both themes
      test_both_themes do
        # Click fullscreen button
        find("[data-action*='fullscreen']").click

        # Verify modal appears
        assert_selector ".modal-fullscreen", visible: true

        # Verify modal uses theme variables
        assert_no_hardcoded_colors(".modal-fullscreen")

        # Close modal
        find(".modal-close").click

        # Verify modal closed
        assert_no_selector ".modal-fullscreen", visible: true
      end
    end
  end

  test "dashboard visual regression" do
    visit root_path

    # Take screenshots in both themes
    UiTestingConfig::THEME_CONFIG[:themes].each do |theme|
      with_theme(theme) do
        # Take screenshot of entire dashboard
        take_component_screenshot("dashboard", theme: theme)

        # Take screenshots of individual components
        if has_selector?(".dashboard-card")
          take_component_screenshot("dashboard_card", theme: theme)
        end

        if has_selector?(".chart-container")
          take_component_screenshot("dashboard_chart", theme: theme)
        end
      end
    end
  end
end
