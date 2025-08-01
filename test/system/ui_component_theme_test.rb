# frozen_string_literal: true

require "application_system_test_case"

class UiComponentThemeTest < ApplicationSystemTestCase
  def setup
    @user = users(:family_admin)
    sign_in(@user)
  end

  test "button components are theme aware" do
    visit lookbook_path

    # Navigate to button component preview
    click_link "Button Component" if page.has_link?("Button Component")

    # Test theme switching on button components
    test_both_themes do
      if page.has_selector?(".btn-modern-primary")
        assert_theme_aware_colors(".btn-modern-primary")
        assert_no_hardcoded_colors(".btn-modern-primary")
      end
    end
  end

  test "card components maintain theme consistency" do
    visit lookbook_path

    # Navigate to card component preview
    click_link "Card Component" if page.has_link?("Card Component")

    if page.has_selector?(".card-modern")
      assert_theme_consistency(".card-modern")

      # Test visual regression
      assert_visual_regression("card", variant: "default", theme: "light")

      toggle_theme
      assert_visual_regression("card", variant: "default", theme: "dark")
    end
  end

  test "dashboard components respect theme switching" do
    visit root_path

    # Test dashboard cards
    if page.has_selector?(".dashboard-card")
      original_theme = current_theme

      # Test in both themes
      test_both_themes do
        page.all(".dashboard-card").each do |card|
          # Verify no hardcoded colors
          assert_no_hardcoded_colors(card)
        end
      end

      # Test theme consistency
      assert_theme_consistency(".dashboard-card")
    end
  end

  test "form components are accessible and theme aware" do
    visit new_account_path if page.has_link?("Add Account")

    # Test form accessibility
    assert_proper_form_labels
    assert_no_accessibility_violations

    # Test theme awareness on form elements
    if page.has_selector?('input[type="text"]')
      test_both_themes do
        assert_theme_aware_colors('input[type="text"]')
      end
    end
  end

  test "navigation components maintain accessibility" do
    visit root_path

    # Test keyboard navigation
    if page.has_selector?("nav a")
      page.all("nav a").each do |link|
        assert_keyboard_navigable(link)
        assert_accessible_name(link)
      end
    end

    # Test theme toggle accessibility
    if page.has_selector?('[data-testid="theme-toggle"]')
      toggle_button = page.find('[data-testid="theme-toggle"]')
      assert_accessible_name(toggle_button)
      assert_keyboard_navigable(toggle_button)
    end
  end

  test "color contrast meets WCAG standards" do
    visit root_path

    # Test common UI elements for sufficient contrast
    selectors_to_test = [
      "button", "a", ".btn-modern-primary", ".btn-modern-secondary",
      "h1", "h2", "h3", "p", ".card-modern"
    ]

    test_both_themes do
      selectors_to_test.each do |selector|
        if page.has_selector?(selector)
          page.all(selector).first(3).each do |element|
            assert_sufficient_color_contrast(element)
          end
        end
      end
    end
  end

  test "reduced motion preferences are respected" do
    visit root_path

    with_reduced_motion do
      # Verify animations are disabled or reduced
      if page.has_selector?(".animate-spin")
        # Check that animations respect reduced motion
        animation_duration = page.evaluate_script(
          "getComputedStyle(document.querySelector('.animate-spin')).animationDuration"
        )

        # Should be 0s or very short when reduced motion is enabled
        assert_includes [ "0s", "0.01s" ], animation_duration
      end
    end
  end

  test "components work across different viewport sizes" do
    # Test mobile viewport
    with_viewport(375, 667) do
      visit root_path

      # Verify responsive behavior
      if page.has_selector?(".dashboard-grid")
        # Should stack on mobile
        grid_columns = page.evaluate_script(
          "getComputedStyle(document.querySelector('.dashboard-grid')).gridTemplateColumns"
        )
        assert_match(/1fr/, grid_columns)
      end
    end

    # Test desktop viewport
    with_viewport(1200, 800) do
      visit root_path

      if page.has_selector?(".dashboard-grid")
        # Should have multiple columns on desktop
        grid_columns = page.evaluate_script(
          "getComputedStyle(document.querySelector('.dashboard-grid')).gridTemplateColumns"
        )
        assert_match(/repeat|1fr.*1fr/, grid_columns)
      end
    end
  end

  visual_regression_test "dashboard_theme_switching" do
    visit root_path

    # Take screenshots in both themes
    with_theme("light") do
      assert_visual_regression("dashboard", theme: "light")
    end

    with_theme("dark") do
      assert_visual_regression("dashboard", theme: "dark")
    end
  end
end
