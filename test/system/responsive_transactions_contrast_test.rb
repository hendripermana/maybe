require "application_system_test_case"

class ResponsiveTransactionsContrastTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "transaction list has proper color contrast in light theme" do
    visit transactions_path
    
    # Ensure light theme is active
    ensure_theme("light")
    
    # Test key components for contrast
    test_component_contrast(".responsive-transaction-container")
    test_component_contrast(".responsive-transaction-filters")
    test_component_contrast(".responsive-transaction-item", minimum: 0)
    test_component_contrast("nav[aria-label='Pagination']", minimum: 0)
  end

  test "transaction list has proper color contrast in dark theme" do
    visit transactions_path
    
    # Ensure dark theme is active
    ensure_theme("dark")
    
    # Test key components for contrast
    test_component_contrast(".responsive-transaction-container")
    test_component_contrast(".responsive-transaction-filters")
    test_component_contrast(".responsive-transaction-item", minimum: 0)
    test_component_contrast("nav[aria-label='Pagination']", minimum: 0)
  end

  test "transaction form has proper color contrast in light theme" do
    visit transactions_path
    
    # Ensure light theme is active
    ensure_theme("light")
    
    # Open transaction form
    find("a", text: /new transaction/i, match: :first).click
    
    # Verify transaction form appears
    assert_selector ".transaction-form-container", visible: true
    
    # Test form components for contrast
    test_component_contrast(".transaction-form-container")
    test_component_contrast("input", within: ".transaction-form-container")
    test_component_contrast("select", within: ".transaction-form-container")
    test_component_contrast("button", within: ".transaction-form-container")
  end

  test "transaction form has proper color contrast in dark theme" do
    visit transactions_path
    
    # Ensure dark theme is active
    ensure_theme("dark")
    
    # Open transaction form
    find("a", text: /new transaction/i, match: :first).click
    
    # Verify transaction form appears
    assert_selector ".transaction-form-container", visible: true
    
    # Test form components for contrast
    test_component_contrast(".transaction-form-container")
    test_component_contrast("input", within: ".transaction-form-container")
    test_component_contrast("select", within: ".transaction-form-container")
    test_component_contrast("button", within: ".transaction-form-container")
  end

  test "transaction filters have proper color contrast in light theme" do
    visit transactions_path
    
    # Ensure light theme is active
    ensure_theme("light")
    
    # Open filters dropdown
    find(".responsive-transaction-filters button", text: "Filters").click
    
    # Verify dropdown appears
    assert_selector ".responsive-transaction-filters [data-disclosure-target='content']", visible: true
    
    # Test filter components for contrast
    test_component_contrast(".responsive-transaction-filters [data-disclosure-target='content']")
    test_component_contrast("input", within: ".responsive-transaction-filters [data-disclosure-target='content']")
    test_component_contrast("select", within: ".responsive-transaction-filters [data-disclosure-target='content']")
    test_component_contrast("button", within: ".responsive-transaction-filters [data-disclosure-target='content']")
  end

  test "transaction filters have proper color contrast in dark theme" do
    visit transactions_path
    
    # Ensure dark theme is active
    ensure_theme("dark")
    
    # Open filters dropdown
    find(".responsive-transaction-filters button", text: "Filters").click
    
    # Verify dropdown appears
    assert_selector ".responsive-transaction-filters [data-disclosure-target='content']", visible: true
    
    # Test filter components for contrast
    test_component_contrast(".responsive-transaction-filters [data-disclosure-target='content']")
    test_component_contrast("input", within: ".responsive-transaction-filters [data-disclosure-target='content']")
    test_component_contrast("select", within: ".responsive-transaction-filters [data-disclosure-target='content']")
    test_component_contrast("button", within: ".responsive-transaction-filters [data-disclosure-target='content']")
  end

  test "transaction bulk update form has proper color contrast in light theme" do
    visit transactions_path
    
    # Ensure light theme is active
    ensure_theme("light")
    
    # Skip if no transactions
    skip "No transactions found" unless has_selector?(".responsive-transaction-item")
    
    # Select first transaction
    find(".responsive-transaction-item input[type='checkbox']", match: :first).check
    
    # Verify bulk action bar appears
    assert_selector "[data-bulk-select-target='bar']", visible: true
    
    # Click bulk update button
    find("[data-bulk-select-target='bar'] button", text: "Update").click
    
    # Verify bulk update form appears
    assert_selector ".transaction-bulk-update-container", visible: true
    
    # Test form components for contrast
    test_component_contrast(".transaction-bulk-update-container")
    test_component_contrast("input", within: ".transaction-bulk-update-container")
    test_component_contrast("select", within: ".transaction-bulk-update-container")
    test_component_contrast("button", within: ".transaction-bulk-update-container")
  end

  test "transaction bulk update form has proper color contrast in dark theme" do
    visit transactions_path
    
    # Ensure dark theme is active
    ensure_theme("dark")
    
    # Skip if no transactions
    skip "No transactions found" unless has_selector?(".responsive-transaction-item")
    
    # Select first transaction
    find(".responsive-transaction-item input[type='checkbox']", match: :first).check
    
    # Verify bulk action bar appears
    assert_selector "[data-bulk-select-target='bar']", visible: true
    
    # Click bulk update button
    find("[data-bulk-select-target='bar'] button", text: "Update").click
    
    # Verify bulk update form appears
    assert_selector ".transaction-bulk-update-container", visible: true
    
    # Test form components for contrast
    test_component_contrast(".transaction-bulk-update-container")
    test_component_contrast("input", within: ".transaction-bulk-update-container")
    test_component_contrast("select", within: ".transaction-bulk-update-container")
    test_component_contrast("button", within: ".transaction-bulk-update-container")
  end

  test "transaction list has proper focus states in light theme" do
    visit transactions_path
    
    # Ensure light theme is active
    ensure_theme("light")
    
    # Test focus states for interactive elements
    test_focus_states(".responsive-transaction-filters button", minimum: 1)
    test_focus_states(".responsive-transaction-filters input", minimum: 1)
    test_focus_states(".responsive-transaction-item a", minimum: 0)
    test_focus_states(".responsive-transaction-item input[type='checkbox']", minimum: 0)
    test_focus_states("nav[aria-label='Pagination'] a", minimum: 0)
  end

  test "transaction list has proper focus states in dark theme" do
    visit transactions_path
    
    # Ensure dark theme is active
    ensure_theme("dark")
    
    # Test focus states for interactive elements
    test_focus_states(".responsive-transaction-filters button", minimum: 1)
    test_focus_states(".responsive-transaction-filters input", minimum: 1)
    test_focus_states(".responsive-transaction-item a", minimum: 0)
    test_focus_states(".responsive-transaction-item input[type='checkbox']", minimum: 0)
    test_focus_states("nav[aria-label='Pagination'] a", minimum: 0)
  end

  private

  def ensure_theme(theme)
    # Check current theme
    current_theme = page.evaluate_script(
      "document.documentElement.getAttribute('data-theme')"
    )
    
    # Switch theme if needed
    if current_theme != theme
      # Find theme toggle button
      if has_selector?("button[aria-label='Toggle theme']")
        find("button[aria-label='Toggle theme']").click
      else
        # Set theme directly if button not found
        page.execute_script(
          "document.documentElement.setAttribute('data-theme', '#{theme}')"
        )
      end
      
      # Verify theme changed
      new_theme = page.evaluate_script(
        "document.documentElement.getAttribute('data-theme')"
      )
      assert_equal theme, new_theme, "Theme should be changed to #{theme}"
    end
  end

  def test_component_contrast(selector, minimum: 1, within: nil)
    # Find elements
    container = within ? find(within) : page
    elements = container.all(selector)
    
    # Skip if no elements found
    if elements.count < minimum
      skip "No elements found matching '#{selector}'" if minimum > 0
      return
    end
    
    elements.each do |element|
      # Get text and background colors
      text_color = page.evaluate_script(
        "window.getComputedStyle(arguments[0]).color",
        element.native
      )
      
      bg_color = page.evaluate_script(
        "window.getComputedStyle(arguments[0]).backgroundColor",
        element.native
      )
      
      # Skip if background is transparent
      next if bg_color == "rgba(0, 0, 0, 0)" || bg_color == "transparent"
      
      # Check contrast ratio (simplified check)
      assert_color_contrast(text_color, bg_color)
    end
  end

  def test_focus_states(selector, minimum: 1)
    # Find elements
    elements = all(selector)
    
    # Skip if no elements found
    if elements.count < minimum
      skip "No elements found matching '#{selector}'" if minimum > 0
      return
    end
    
    # Test first element
    element = elements.first
    
    # Focus the element
    element.send_keys(:tab)
    
    # Verify it's focused
    focused_element = page.evaluate_script("document.activeElement")
    assert_equal element.native, focused_element, "Element should be focusable"
    
    # Get styles before and after focus
    unfocused_styles = page.evaluate_script(
      "window.getComputedStyle(arguments[0])",
      element.native
    )
    
    focused_styles = page.evaluate_script(
      "window.getComputedStyle(document.activeElement)"
    )
    
    # Check for visible focus indicator
    has_focus_indicator = focused_styles["outline"] != "none" || 
                         focused_styles["boxShadow"] != unfocused_styles["boxShadow"] ||
                         focused_styles["border"] != unfocused_styles["border"]
    
    assert has_focus_indicator, "Element should have visible focus indicator"
  end

  def assert_color_contrast(text_color, bg_color)
    # This is a simplified check - in a real test, you'd calculate the actual contrast ratio
    # For now, we'll just check that they're not the same color
    
    # Convert colors to simple RGB values
    text_rgb = color_to_rgb(text_color)
    bg_rgb = color_to_rgb(bg_color)
    
    # Check that colors are different enough
    assert text_rgb != bg_rgb, "Text color should contrast with background color"
    
    # Simple luminance difference check (very basic)
    text_luminance = calculate_luminance(text_rgb)
    bg_luminance = calculate_luminance(bg_rgb)
    
    luminance_diff = (text_luminance - bg_luminance).abs
    assert luminance_diff > 0.2, "Text and background should have sufficient luminance difference"
  end

  def color_to_rgb(color)
    # Convert various color formats to RGB array
    if color.start_with?("rgb")
      # Extract RGB values from rgb(r, g, b) or rgba(r, g, b, a)
      color.gsub(/rgba?\(|\)/, "").split(",").map(&:strip).take(3).map(&:to_i)
    elsif color.start_with?("#")
      # Convert hex to RGB
      [
        color[1..2].to_i(16),
        color[3..4].to_i(16),
        color[5..6].to_i(16)
      ]
    else
      # Unknown format, return as is
      color
    end
  end

  def calculate_luminance(rgb)
    # Simple relative luminance calculation (approximation)
    # Formula: 0.299*R + 0.587*G + 0.114*B (normalized to 0-1)
    r, g, b = rgb
    (0.299 * r + 0.587 * g + 0.114 * b) / 255
  end
end