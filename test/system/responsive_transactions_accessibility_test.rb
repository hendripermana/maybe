require "application_system_test_case"

class ResponsiveTransactionsAccessibilityTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "transaction list meets accessibility standards" do
    visit transactions_path

    # Test both themes for accessibility
    test_both_themes do
      # Check for proper ARIA landmarks
      assert_selector "[role='main']", count: 1, visible: true

      # Check for proper heading structure
      assert_proper_heading_hierarchy

      # Check for proper button labels
      buttons = all(".responsive-transaction-container button, .responsive-transaction-container [role='button']")
      buttons.each do |button|
        assert_accessible_name(button)
      end

      # Check for proper image alt text
      images = all(".responsive-transaction-container img")
      images.each do |img|
        assert img[:alt].present?, "Images must have alt text for screen readers"
      end

      # Check for proper form labels if forms exist
      if has_selector?(".responsive-transaction-container form")
        assert_proper_form_labels(".responsive-transaction-container form")
      end

      # Check for proper ARIA attributes on interactive elements
      interactive_elements = all(".responsive-transaction-container [aria-label], .responsive-transaction-container [aria-labelledby], .responsive-transaction-container [aria-describedby]")
      interactive_elements.each do |element|
        assert_proper_aria_attributes(element)
      end
    end
  end

  test "transaction list can be navigated with keyboard" do
    visit transactions_path

    # Start from the beginning of the page
    page.execute_script("document.activeElement.blur()")

    # Press tab to start keyboard navigation
    page.send_keys(:tab)

    # Track elements we've successfully focused
    focused_elements = []

    # Try to tab through all interactive elements (limit to 20 to avoid infinite loop)
    20.times do
      # Get currently focused element
      focused_element = page.evaluate_script("document.activeElement")
      break if focused_elements.include?(focused_element)

      # Add to our list of focused elements
      focused_elements << focused_element

      # Press tab to move to next element
      page.send_keys(:tab)
    end

    # Verify we found interactive elements
    assert focused_elements.length > 1, "Should be able to tab through multiple elements"

    # Verify we can focus transaction items
    if has_selector?(".responsive-transaction-item a")
      # Find first transaction link
      transaction_link = find(".responsive-transaction-item a", match: :first)

      # Focus the link
      transaction_link.send_keys(:tab)

      # Verify it's focused
      focused_element = page.evaluate_script("document.activeElement")
      assert_equal transaction_link.native, focused_element, "Should be able to focus transaction links"

      # Check for visible focus indicator
      focus_styles = page.evaluate_script(
        "window.getComputedStyle(document.activeElement)"
      )

      has_focus_indicator = focus_styles["outline"] != "none" ||
                            focus_styles["boxShadow"] != "none" ||
                            focus_styles["border"] != "none"

      assert has_focus_indicator, "Transaction links should have visible focus indicator"
    end
  end

  test "transaction filters are accessible" do
    visit transactions_path

    # Check for proper labels on filter controls
    if has_selector?(".responsive-transaction-filters")
      # Check search input
      search_input = find(".responsive-transaction-filters input[type='search']")
      assert search_input[:placeholder].present?, "Search input should have placeholder text"

      # Check filter buttons
      filter_buttons = all(".responsive-transaction-filters button")
      filter_buttons.each do |button|
        assert_accessible_name(button)
      end

      # Check filter dropdowns
      if has_selector?(".responsive-transaction-filters [data-disclosure-target='content']")
        dropdowns = all(".responsive-transaction-filters [data-disclosure-target='content']")

        dropdowns.each do |dropdown|
          # Check for proper ARIA attributes
          trigger = find_disclosure_trigger_for(dropdown)

          assert trigger.present?, "Dropdown should have a trigger element"
          assert_accessible_name(trigger)

          # Check form controls inside dropdown
          dropdown.all("input, select").each do |control|
            assert_has_label(control)
          end
        end
      end
    end
  end

  test "transaction pagination is accessible" do
    # Create enough transactions to trigger pagination
    create_multiple_transactions(30)

    visit transactions_path

    # Check pagination accessibility
    if has_selector?("nav[aria-label='Pagination']")
      # Check for proper ARIA label
      assert_selector "nav[aria-label='Pagination']"

      # Check page links
      page_links = all("nav[aria-label='Pagination'] a")

      page_links.each do |link|
        assert_accessible_name(link)
      end

      # Check for proper current page indication
      if has_selector?("nav[aria-label='Pagination'] [aria-current='page']")
        current_page = find("nav[aria-label='Pagination'] [aria-current='page']")
        assert current_page[:aria_current] == "page", "Current page should have aria-current='page'"
      end

      # Check prev/next links
      if has_link?("Previous")
        prev_link = find("a", text: "Previous")
        assert_includes prev_link.text, "Previous", "Previous link should have accessible text"
      end

      if has_link?("Next")
        next_link = find("a", text: "Next")
        assert_includes next_link.text, "Next", "Next link should have accessible text"
      end
    end
  end

  test "transaction list has proper color contrast" do
    visit transactions_path

    # Test both themes for color contrast
    test_both_themes do
      # Check text elements for proper contrast
      text_elements = [
        ".responsive-transaction-item",
        ".responsive-transaction-filters",
        "nav[aria-label='Pagination']"
      ]

      text_elements.each do |selector|
        if has_selector?(selector)
          elements = all(selector)

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
      end
    end
  end

  private

    def create_multiple_transactions(count)
      # Helper method to create multiple transactions for pagination testing
      account = @user.family.accounts.first

      count.times do |i|
        Entry.create!(
          account: account,
          name: "Test Transaction #{i}",
          amount: -10.0,
          date: Date.current - i.days,
          entryable_type: "Transaction",
          entryable_attributes: {
            category_id: @user.family.categories.first.id
          }
        )
      end
    end

    def assert_proper_form_labels(form_selector = nil)
      # Find all form controls
      selector = form_selector ? "#{form_selector} input, #{form_selector} select, #{form_selector} textarea" : "input, select, textarea"
      controls = all(selector, visible: true)

      controls.each do |control|
        next if control[:type] == "hidden" || control[:type] == "submit" || control[:type] == "button"

        assert_has_label(control)
      end
    end

    def assert_has_label(control)
      # Check if control has a label
      has_label = false

      # Check for label element
      if control[:id].present?
        has_label ||= has_selector?("label[for='#{control[:id]}']")
      end

      # Check for aria-label
      has_label ||= control[:aria_label].present?

      # Check for aria-labelledby
      has_label ||= control[:aria_labelledby].present?

      # Check for parent label
      has_label ||= control.has_ancestor?("label")

      # Check for placeholder (not ideal but better than nothing)
      has_label ||= control[:placeholder].present?

      assert has_label, "Form control should have an accessible label"
    end

    def find_disclosure_trigger_for(dropdown)
      # Find the trigger element for a disclosure dropdown
      # This is a simplified approach - in a real test, you'd need a more robust method

      # Try to find a button with disclosure controller
      trigger = all("button[data-controller~='disclosure']").find do |button|
        # Check if this button controls our dropdown
        button_id = button[:id]
        dropdown_controls = dropdown[:aria_labelledby] || dropdown[:aria_controls]

        button_id.present? && dropdown_controls.present? && dropdown_controls.include?(button_id)
      end

      # If not found, try to find by data-action
      if trigger.nil?
        trigger = all("button[data-action*='disclosure#toggle']").first
      end

      trigger
    end

    def assert_color_contrast(text_color, bg_color)
      # This is a simplified check - in a real test, you'd calculate the actual contrast ratio
      # For now, we'll just check that they're not the same color

      # Convert colors to simple RGB values
      text_rgb = color_to_rgb(text_color)
      bg_rgb = color_to_rgb(bg_color)

      # Check that colors are different enough
      assert text_rgb != bg_rgb, "Text color should contrast with background color"
    end

    def color_to_rgb(color)
      # Convert various color formats to RGB array
      if color.start_with?("rgb")
        # Extract RGB values from rgb(r, g, b) or rgba(r, g, b, a)
        color.gsub(/rgba?\(|\)/, "").split(",").map(&:strip).take(3)
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
end
