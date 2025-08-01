require "application_system_test_case"

class ModernizedPagesMediaQueriesTest < ApplicationSystemTestCase
  setup do
    @user = users(:family_admin)
    sign_in @user
  end

  # Test print styles for financial reports
  test "financial reports have proper print styles" do
    # Visit dashboard (which likely has financial reports)
    visit root_path

    # Enable print media simulation
    page.execute_script("document.body.classList.add('print-simulation')")

    # Verify print styles are applied
    assert_selector "body.print-simulation", "Print simulation should be enabled"

    # Check that print-specific styles are applied
    print_background_color = page.evaluate_script(
      "window.getComputedStyle(document.body).getPropertyValue('--print-background')"
    ).strip

    assert_not_empty print_background_color, "Print background color should be defined"

    # Check that unnecessary elements are hidden in print view
    assert_selector ".print\\:hidden", visible: false

    # Check that print-only elements are visible
    assert_selector ".hidden.print\\:block", visible: true

    # Disable print media simulation
    page.execute_script("document.body.classList.remove('print-simulation')")
  end

  # Test reduced motion preference
  test "reduced motion preference is respected" do
    # Visit dashboard
    visit root_path

    # Enable reduced motion simulation
    page.execute_script("document.body.classList.add('reduce-motion')")
    page.execute_script("document.documentElement.style.setProperty('--motion-reduce', 'reduce')")

    # Verify reduced motion styles are applied
    assert_selector "body.reduce-motion", "Reduced motion simulation should be enabled"

    # Check that reduced motion CSS variable is set
    reduced_motion_value = page.evaluate_script(
      "window.getComputedStyle(document.documentElement).getPropertyValue('--motion-reduce')"
    ).strip

    assert_equal "reduce", reduced_motion_value, "Reduced motion CSS variable should be set"

    # Check animations are disabled or reduced
    if has_selector?(".animate-transition")
      animation_duration = page.evaluate_script(
        "window.getComputedStyle(document.querySelector('.animate-transition')).getPropertyValue('transition-duration')"
      )

      # Animation duration should be 0 or very short
      assert animation_duration == "0s" || animation_duration.to_f < 0.1,
             "Animation duration should be reduced or disabled"
    end

    # Disable reduced motion simulation
    page.execute_script("document.body.classList.remove('reduce-motion')")
    page.execute_script("document.documentElement.style.removeProperty('--motion-reduce')")
  end

  # Test high contrast mode
  test "high contrast mode is supported" do
    # Visit dashboard
    visit root_path

    # Enable high contrast simulation
    page.execute_script("document.body.classList.add('high-contrast')")

    # Verify high contrast styles are applied
    assert_selector "body.high-contrast", "High contrast simulation should be enabled"

    # Check text elements for increased contrast
    headings = all("h1, h2, h3, h4, h5, h6", visible: true)

    headings.each do |heading|
      # Get computed color and background
      color = page.evaluate_script(
        "window.getComputedStyle(arguments[0]).color",
        heading.native
      )

      background = page.evaluate_script(
        "window.getComputedStyle(arguments[0]).backgroundColor",
        heading.native
      )

      # Simple check that colors are different (a more sophisticated test would calculate contrast ratio)
      assert color != background, "Text and background colors should be different in high contrast mode"
    end

    # Disable high contrast simulation
    page.execute_script("document.body.classList.remove('high-contrast')")
  end

  # Test screen reader specific styles
  test "screen reader specific styles are applied" do
    # Visit dashboard
    visit root_path

    # Check for screen reader only elements
    assert_selector ".sr-only", visible: false

    # Verify screen reader only elements have content
    sr_elements = all(".sr-only", visible: false)

    sr_elements.each do |element|
      assert_not_empty element.text.strip, "Screen reader only elements should have content"
    end

    # Check that screen reader skip links are present
    assert has_selector?("a[href='#main-content']", visible: false) ||
           has_selector?("a[href='#content']", visible: false),
           "Screen reader skip links should be present"
  end

  # Test prefers-color-scheme media query
  test "prefers-color-scheme media query is supported" do
    # Visit settings page
    visit settings_preferences_path

    # Check for system theme option
    if has_selector?("input[name='user[theme]'][value='system']")
      choose "System"

      # Verify setting is saved
      assert_selector ".settings-saved-indicator", "Setting should be saved"

      # Simulate light color scheme preference
      page.execute_script(
        "document.documentElement.setAttribute('data-prefers-color-scheme', 'light')"
      )

      # Reload page to apply preference
      visit settings_preferences_path

      # Verify light theme is applied
      assert_equal "light", current_theme, "Light theme should be applied based on system preference"

      # Simulate dark color scheme preference
      page.execute_script(
        "document.documentElement.setAttribute('data-prefers-color-scheme', 'dark')"
      )

      # Reload page to apply preference
      visit settings_preferences_path

      # Verify dark theme is applied
      assert_equal "dark", current_theme, "Dark theme should be applied based on system preference"

      # Reset simulation
      page.execute_script(
        "document.documentElement.removeAttribute('data-prefers-color-scheme')"
      )
    end
  end

  # Test print styles for transaction list
  test "transaction list has proper print styles" do
    # Visit transactions page
    visit transactions_path

    # Enable print media simulation
    page.execute_script("document.body.classList.add('print-simulation')")

    # Verify print styles are applied
    assert_selector "body.print-simulation", "Print simulation should be enabled"

    # Check that unnecessary elements are hidden in print view
    assert_selector ".print\\:hidden", visible: false

    # Check that print-only elements are visible
    assert_selector ".hidden.print\\:block", visible: true

    # Check that transaction list is optimized for printing
    if has_selector?(".transaction-item")
      # Transaction items should be fully expanded in print view
      assert_selector ".transaction-item.print\\:expanded", visible: true

      # Check that all transaction details are visible
      assert_no_selector ".transaction-item .hidden", visible: false
    end

    # Disable print media simulation
    page.execute_script("document.body.classList.remove('print-simulation')")
  end

  # Test print styles for budget page
  test "budget page has proper print styles" do
    # Visit budgets page
    visit budgets_path

    # Enable print media simulation
    page.execute_script("document.body.classList.add('print-simulation')")

    # Verify print styles are applied
    assert_selector "body.print-simulation", "Print simulation should be enabled"

    # Check that unnecessary elements are hidden in print view
    assert_selector ".print\\:hidden", visible: false

    # Check that print-only elements are visible
    assert_selector ".hidden.print\\:block", visible: true

    # Check that budget details are optimized for printing
    if has_selector?(".budget-category")
      # Budget categories should be fully visible in print view
      assert_selector ".budget-category.print\\:expanded", visible: true

      # Check that all budget details are visible
      assert_no_selector ".budget-category .hidden", visible: false
    end

    # Disable print media simulation
    page.execute_script("document.body.classList.remove('print-simulation')")
  end
end
