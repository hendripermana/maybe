module SettingsTestHelper
  # Helper method to open settings from sidebar
  def open_settings_from_sidebar
    within "div[data-testid=user-menu]" do
      find("button").click
    end
    click_link "Settings"
  end

  # Helper method to navigate to a specific settings section
  def navigate_to_settings_section(section_name)
    open_settings_from_sidebar
    click_link section_name
  end

  # Helper method to toggle a setting
  def toggle_setting(label_text)
    find("label", text: label_text).click
    sleep 0.5 # Wait for auto-save
  end

  # Helper method to select an option from a dropdown
  def select_setting_option(option_text, from:)
    select option_text, from: from
    sleep 0.5 # Wait for auto-save
  end

  # Helper method to check if a setting is enabled
  def setting_enabled?(name)
    has_selector?("input[name='#{name}'][checked]")
  end

  # Helper method to check if a theme is selected
  def theme_selected?(theme)
    has_selector?("input[name='user[theme]'][value='#{theme}'][checked]")
  end

  # Helper method to check if a select option is selected
  def option_selected?(option_text, select_name)
    has_selector?("select[name='#{select_name}'] option[selected]", text: option_text)
  end

  # Helper method to test keyboard navigation
  def tab_through_form(count = 10)
    count.times do
      page.driver.browser.action.send_keys(:tab).perform
      assert_selector ":focus", count: 1
    end
  end

  # Helper method to test screen reader accessibility
  def assert_screen_reader_accessible
    # Check for proper ARIA attributes
    assert_selector "[aria-label]"
    assert_selector "[role]"

    # Check for proper heading hierarchy
    assert_selector "h1"

    # Check for form labels
    assert_selector "label[for]"
  end
end

# Include the helper in system tests
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include SettingsTestHelper
end
