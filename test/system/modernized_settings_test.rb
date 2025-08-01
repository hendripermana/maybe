require "application_system_test_case"

class ModernizedSettingsTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)

    @settings_links = [
      [ "Account", settings_profile_path ],
      [ "Preferences", settings_preferences_path ],
      [ "Accounts", accounts_path ],
      [ "Tags", tags_path ],
      [ "Categories", categories_path ],
      [ "Merchants", family_merchants_path ],
      [ "Imports", imports_path ],
      [ "What's new", changelog_path ],
      [ "Feedback", feedback_path ]
    ]
  end

  test "can navigate through all settings sections" do
    open_settings_from_sidebar
    assert_selector "h1", text: "Account"
    assert_current_path settings_profile_path, ignore_query: true

    @settings_links.each do |name, path|
      click_link name
      assert_selector "h1", text: name
      assert_current_path path
    end
  end

  test "theme preferences save and load correctly" do
    visit settings_preferences_path

    # Test light theme selection
    find("label[for='user_theme_light']").click
    # Wait for auto-save to complete
    sleep 0.5

    # Reload page to verify persistence
    visit settings_preferences_path
    assert_selector "input[name='user[theme]'][value='light'][checked]"

    # Test dark theme selection
    find("label[for='user_theme_dark']").click
    sleep 0.5

    # Reload page to verify persistence
    visit settings_preferences_path
    assert_selector "input[name='user[theme]'][value='dark'][checked]"

    # Test system theme selection
    find("label[for='user_theme_system']").click
    sleep 0.5

    # Reload page to verify persistence
    visit settings_preferences_path
    assert_selector "input[name='user[theme]'][value='system'][checked]"
  end

  test "language and timezone settings save correctly" do
    visit settings_preferences_path

    # Test language selection
    select "Español", from: "family[locale]"
    sleep 0.5

    # Reload page to verify persistence
    visit settings_preferences_path
    assert_selector "select[name='family[locale]'] option[selected]", text: "Español"

    # Reset to English
    select "English", from: "family[locale]"
    sleep 0.5
  end

  test "notification preferences save correctly" do
    visit settings_preferences_path

    # Toggle email notifications
    find("label", text: I18n.t("settings.preferences.show.receive_email_notifications")).click
    sleep 0.5

    # Reload page to verify persistence
    visit settings_preferences_path

    # Check if the toggle is in the correct state
    # This depends on the initial state, so we need to check both possibilities
    if @user.email_notifications
      assert_selector "input[name='user[email_notifications]'][checked]"
    else
      assert_no_selector "input[name='user[email_notifications]'][checked]"
    end

    # Test notification frequency selection
    find("label", text: I18n.t("settings.preferences.show.weekly")).click
    sleep 0.5

    # Reload page to verify persistence
    visit settings_preferences_path
    assert_selector "input[name='user[notification_frequency]'][value='weekly'][checked]"
  end

  test "privacy settings save correctly" do
    visit settings_preferences_path

    # Toggle data sharing
    find("label", text: I18n.t("settings.preferences.show.allow_data_collection")).click
    sleep 0.5

    # Reload page to verify persistence
    visit settings_preferences_path

    # Check if the checkbox is in the correct state
    # This depends on the initial state, so we need to check both possibilities
    if @user.data_sharing
      assert_selector "input[name='user[data_sharing]'][checked]"
    else
      assert_no_selector "input[name='user[data_sharing]'][checked]"
    end

    # Toggle marketing emails
    find("label", text: I18n.t("settings.preferences.show.receive_marketing_emails")).click
    sleep 0.5

    # Reload page to verify persistence
    visit settings_preferences_path

    # Check if the checkbox is in the correct state
    if @user.marketing_emails
      assert_selector "input[name='user[marketing_emails]'][checked]"
    else
      assert_no_selector "input[name='user[marketing_emails]'][checked]"
    end
  end

  test "accessibility compliance for settings controls" do
    visit settings_preferences_path

    # Test for proper form labels
    assert_selector "label[for='family_locale']"
    assert_selector "label[for='family_timezone']"
    assert_selector "label[for='family_date_format']"

    # Test for proper ARIA attributes on theme switcher
    assert_selector "[data-controller='theme']"
    assert_selector "input[type='radio'][name='user[theme]']"

    # Test for proper ARIA attributes on toggle switches
    assert_selector "input[role='switch']"

    # Test for proper help text associations
    assert_selector ".form-field-help-text"
  end

  test "keyboard navigation works correctly" do
    visit settings_preferences_path

    # Focus the first form element
    find("select[name='family[locale]']").send_keys(:tab)

    # Tab through all interactive elements and ensure focus moves correctly
    10.times do
      page.driver.browser.action.send_keys(:tab).perform
      assert_selector ":focus", count: 1
    end

    # Test that radio buttons can be controlled with keyboard
    find("input[name='user[theme]'][value='light']").send_keys(:space)
    assert_selector "input[name='user[theme]'][value='light'][checked]"
  end

  test "high contrast mode toggle works correctly" do
    visit settings_preferences_path

    # Toggle high contrast mode
    find("label", text: I18n.t("settings.preferences.show.enable_high_contrast")).click
    sleep 0.5

    # Reload page to verify persistence
    visit settings_preferences_path

    # Check if the toggle is in the correct state
    if @user.high_contrast_mode
      assert_selector "input[name='user[high_contrast_mode]'][checked]"
    else
      assert_no_selector "input[name='user[high_contrast_mode]'][checked]"
    end
  end

  test "reduced motion preference works correctly" do
    visit settings_preferences_path

    # Toggle reduced motion
    find("label", text: I18n.t("settings.preferences.show.enable_reduced_motion")).click
    sleep 0.5

    # Reload page to verify persistence
    visit settings_preferences_path

    # Check if the toggle is in the correct state
    if @user.reduced_motion
      assert_selector "input[name='user[reduced_motion]'][checked]"
    else
      assert_no_selector "input[name='user[reduced_motion]'][checked]"
    end
  end

  test "font size selection works correctly" do
    visit settings_preferences_path

    # Select large font size
    select I18n.t("settings.preferences.show.font_size_large"), from: "user[font_size]"
    sleep 0.5

    # Reload page to verify persistence
    visit settings_preferences_path
    assert_selector "select[name='user[font_size]'] option[selected]", text: I18n.t("settings.preferences.show.font_size_large")
  end

  private

    def open_settings_from_sidebar
      within "div[data-testid=user-menu]" do
        find("button").click
      end
      click_link "Settings"
    end
end
