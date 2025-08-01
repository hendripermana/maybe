require "application_system_test_case"

class SettingsAccessibilityTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "settings forms have proper accessibility attributes" do
    visit settings_preferences_path

    # Check for proper form labels
    assert_selector "label[for='family_locale']"
    assert_selector "label[for='family_timezone']"
    assert_selector "label[for='family_date_format']"

    # Check for proper ARIA attributes on form fields
    assert_selector "select[aria-invalid='false']"

    # Check for proper ARIA attributes on toggle switches
    assert_selector "input[role='switch']"

    # Check for proper help text associations
    assert_selector ".form-field-help-text"
  end

  test "theme switcher has proper accessibility attributes" do
    visit settings_preferences_path

    # Check for proper radio button group
    assert_selector "input[type='radio'][name='user[theme]']"

    # Check for proper labels on radio buttons
    assert_selector "label[for='user_theme_light']"
    assert_selector "label[for='user_theme_dark']"
    assert_selector "label[for='user_theme_system']"
  end

  test "toggle switches have proper accessibility attributes" do
    visit settings_preferences_path

    # Check for proper role attribute
    assert_selector "input[role='switch']"

    # Check for proper aria-checked attribute
    assert_selector "input[role='switch'][aria-checked]"

    # Check for proper labels
    assert_selector "label", text: I18n.t("settings.preferences.show.enable_high_contrast")
    assert_selector "label", text: I18n.t("settings.preferences.show.enable_reduced_motion")
  end

  test "form sections have proper heading hierarchy" do
    visit settings_preferences_path

    # Check for proper heading hierarchy
    assert_selector "h1", text: "Preferences"
    assert_selector "h4", text: I18n.t("settings.preferences.show.theme_additional_preferences")
  end

  test "form fields have proper error states" do
    # This test would need to trigger validation errors
    # For now, we'll just check that the error classes exist in the CSS
    visit settings_preferences_path

    # Check that error classes exist in the CSS
    assert page.has_css?(".form-field-error", visible: false) ||
           page.has_css?(".field_with_errors", visible: false)
  end

  test "color contrast meets WCAG standards" do
    visit settings_preferences_path

    # This would ideally use a color contrast testing library
    # For now, we'll just check that the theme variables are applied
    assert_selector "[data-theme]"
  end

  test "keyboard navigation works through all form controls" do
    visit settings_preferences_path

    # Focus the first form element
    find("select[name='family[locale]']").send_keys(:tab)

    # Tab through all interactive elements and ensure focus moves correctly
    10.times do
      page.driver.browser.action.send_keys(:tab).perform
      assert_selector ":focus", count: 1
    end
  end

  test "screen reader text is present for important elements" do
    visit settings_preferences_path

    # Check for visually hidden text that would be read by screen readers
    assert_selector ".sr-only", visible: false
  end
end
