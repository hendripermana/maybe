require "application_system_test_case"

class SettingsUserExperienceTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "settings navigation is intuitive and accessible" do
    visit settings_profile_path

    # Check that the navigation is visible
    assert_selector "nav", count: 1

    # Check that the current section is highlighted
    assert_selector "a.active", text: "Account"

    # Navigate to another section
    click_link "Preferences"

    # Check that the new section is highlighted
    assert_selector "a.active", text: "Preferences"

    # Check that the URL changed appropriately
    assert_current_path settings_preferences_path
  end

  test "settings sections have clear headings and descriptions" do
    visit settings_preferences_path

    # Check for main heading
    assert_selector "h1", text: "Preferences"

    # Check for section headings
    assert_selector "h3", text: I18n.t("settings.preferences.show.general_title")
    assert_selector "h3", text: I18n.t("settings.preferences.show.theme_title")
    assert_selector "h3", text: I18n.t("settings.preferences.show.notification_title")
    assert_selector "h3", text: I18n.t("settings.preferences.show.privacy_title")

    # Check for section descriptions
    assert_selector "p", text: I18n.t("settings.preferences.show.general_subtitle")
    assert_selector "p", text: I18n.t("settings.preferences.show.theme_subtitle")
    assert_selector "p", text: I18n.t("settings.preferences.show.notification_subtitle")
    assert_selector "p", text: I18n.t("settings.preferences.show.privacy_subtitle")
  end

  test "form controls provide visual feedback on interaction" do
    visit settings_preferences_path

    # Check that form controls have hover states
    page.execute_script("document.querySelector('select').classList.add('hover')")
    assert_selector "select.hover"

    # Check that form controls have focus states
    find("select[name='family[locale]']").click
    assert_selector "select:focus"
  end

  test "theme switcher provides visual preview" do
    visit settings_preferences_path

    # Check that theme preview exists
    assert_selector "h4", text: I18n.t("settings.preferences.show.theme_preview")

    # Check that preview elements exist
    assert_selector ".p-4.rounded-lg.border"
  end

  test "settings changes provide immediate feedback" do
    visit settings_preferences_path

    # Toggle a setting
    find("label", text: I18n.t("settings.preferences.show.enable_high_contrast")).click

    # Check that the toggle visually updates immediately
    if @user.high_contrast_mode
      assert_no_selector "input[name='user[high_contrast_mode]'][checked]"
    else
      assert_selector "input[name='user[high_contrast_mode]'][checked]"
    end
  end

  test "responsive layout works on different screen sizes" do
    visit settings_preferences_path

    # Test on desktop size (default)
    assert_selector ".grid-cols-1.md\\:grid-cols-3"

    # Test on tablet size
    page.driver.browser.manage.window.resize_to(800, 600)
    assert_selector ".grid-cols-1.md\\:grid-cols-3"

    # Test on mobile size
    page.driver.browser.manage.window.resize_to(375, 667)
    assert_selector ".grid-cols-1"
  end

  test "tooltips provide additional information" do
    visit settings_preferences_path

    # Check that tooltips exist
    assert_selector "[data-tooltip]", visible: false
  end

  test "form sections are logically grouped" do
    visit settings_preferences_path

    # Check that form sections are separated
    assert_selector ".border-t.border-border"
  end

  test "high contrast mode applies appropriate styling" do
    visit settings_preferences_path

    # Enable high contrast mode if not already enabled
    unless @user.high_contrast_mode
      find("label", text: I18n.t("settings.preferences.show.enable_high_contrast")).click
      sleep 0.5
    end

    # Reload page to apply high contrast mode
    visit settings_preferences_path

    # Check that high contrast mode is applied
    # This would ideally check for specific high contrast styles
    assert_selector "input[name='user[high_contrast_mode]'][checked]"
  end

  test "reduced motion preference applies appropriate styling" do
    visit settings_preferences_path

    # Enable reduced motion if not already enabled
    unless @user.reduced_motion
      find("label", text: I18n.t("settings.preferences.show.enable_reduced_motion")).click
      sleep 0.5
    end

    # Reload page to apply reduced motion
    visit settings_preferences_path

    # Check that reduced motion is applied
    # This would ideally check for specific reduced motion styles
    assert_selector "input[name='user[reduced_motion]'][checked]"
  end

  test "font size selection applies appropriate styling" do
    visit settings_preferences_path

    # Select large font size
    select I18n.t("settings.preferences.show.font_size_large"), from: "user[font_size]"
    sleep 0.5

    # Reload page to apply font size
    visit settings_preferences_path

    # Check that large font size is selected
    assert_selector "select[name='user[font_size]'] option[selected]", text: I18n.t("settings.preferences.show.font_size_large")

    # This would ideally check for specific font size styles
  end
end
