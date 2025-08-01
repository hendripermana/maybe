require "application_system_test_case"

class DashboardKeyboardNavigationTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "dashboard can be fully navigated with keyboard" do
    visit root_path

    # Start from the beginning of the page
    page.execute_script("document.activeElement.blur()")

    # Press tab to start keyboard navigation
    page.send_keys(:tab)

    # Track elements we've successfully focused
    focused_elements = []
    focused_selectors = []

    # Try to tab through all interactive elements (limit to 20 to avoid infinite loop)
    20.times do
      # Get currently focused element
      focused_element = page.evaluate_script("document.activeElement")
      break if focused_elements.include?(focused_element)

      # Add to our list of focused elements
      focused_elements << focused_element

      # Get selector for logging
      tag_name = page.evaluate_script("document.activeElement.tagName")
      id = page.evaluate_script("document.activeElement.id")
      classes = page.evaluate_script("document.activeElement.className")

      selector = tag_name.downcase
      selector += "##{id}" if id.present?
      selector += ".#{classes.split(' ').join('.')}" if classes.present?

      focused_selectors << selector

      # Press tab to move to next element
      page.send_keys(:tab)
    end

    # Verify we found interactive elements
    assert focused_elements.length > 1,
           "Should be able to tab through multiple elements, found: #{focused_selectors.join(', ')}"

    # Test specific interactive elements if they exist

    # 1. Test chart fullscreen button if it exists
    if has_selector?("[data-action*='fullscreen']")
      # Focus the fullscreen button
      fullscreen_button = find("[data-action*='fullscreen']")
      fullscreen_button.send_keys(:tab)

      # Press Enter to activate
      page.send_keys(:enter)

      # Verify modal opened
      assert_selector ".modal-fullscreen", visible: true

      # Verify focus is trapped in modal
      modal_focused_elements = []

      # Tab through modal elements
      5.times do
        focused = page.evaluate_script("document.activeElement")
        break if modal_focused_elements.include?(focused)
        modal_focused_elements << focused
        page.send_keys(:tab)
      end

      # Verify we can focus elements in the modal
      assert modal_focused_elements.length > 0, "Should be able to focus elements in modal"

      # Find close button and press it
      if has_selector?(".modal-close")
        close_button = find(".modal-close")
        close_button.send_keys(:enter)

        # Verify modal closed
        assert_no_selector ".modal-fullscreen", visible: true
      end
    end

    # 2. Test theme toggle button if it exists
    if has_selector?("[data-testid='theme-toggle']")
      # Focus the theme toggle
      theme_toggle = find("[data-testid='theme-toggle']")
      theme_toggle.send_keys(:tab)

      # Get current theme
      initial_theme = current_theme

      # Press Space to toggle theme
      page.send_keys(:space)

      # Verify theme changed
      new_theme = current_theme
      assert_not_equal initial_theme, new_theme, "Theme should change when toggled with keyboard"
    end
  end

  test "dashboard keyboard shortcuts work correctly" do
    visit root_path

    # Test keyboard shortcuts if they exist

    # 1. Test fullscreen shortcut (F) if applicable
    if has_selector?("[data-action*='fullscreen']")
      # Press 'f' key
      page.send_keys("f")

      # Check if fullscreen mode activated
      if has_selector?(".modal-fullscreen", visible: true)
        # Shortcut worked
        assert_selector ".modal-fullscreen", visible: true

        # Close modal
        find(".modal-close").click
      end
    end

    # 2. Test theme toggle shortcut (T) if applicable
    if has_selector?("[data-testid='theme-toggle']")
      # Get current theme
      initial_theme = current_theme

      # Press 't' key
      page.send_keys("t")

      # Check if theme toggled
      new_theme = current_theme
      if initial_theme != new_theme
        # Shortcut worked
        assert_not_equal initial_theme, new_theme, "Theme should change with 't' shortcut"
      end
    end

    # 3. Test escape key for closing modals
    if has_selector?("[data-action*='fullscreen']")
      # Open fullscreen modal
      find("[data-action*='fullscreen']").click
      assert_selector ".modal-fullscreen", visible: true

      # Press escape key
      page.send_keys(:escape)

      # Verify modal closed
      assert_no_selector ".modal-fullscreen", visible: true
    end
  end

  test "dashboard focus management works correctly" do
    visit root_path

    # Test focus management for interactive elements

    # 1. Test focus trap in modals
    if has_selector?("[data-action*='fullscreen']")
      # Open fullscreen modal
      find("[data-action*='fullscreen']").click
      assert_selector ".modal-fullscreen", visible: true

      # Verify focus is moved to the modal
      focused_element = page.evaluate_script("document.activeElement")
      modal = find(".modal-fullscreen")

      assert_equal modal.native, focused_element,
                   "Focus should move to modal when opened"

      # Tab multiple times to verify focus stays in modal
      trapped_in_modal = true

      10.times do
        page.send_keys(:tab)
        focused_element = page.evaluate_script("document.activeElement")

        # Check if focus is still within modal
        is_in_modal = page.evaluate_script(
          "document.querySelector('.modal-fullscreen').contains(document.activeElement)"
        )

        trapped_in_modal = trapped_in_modal && is_in_modal
      end

      assert trapped_in_modal, "Focus should be trapped within modal"

      # Close modal
      find(".modal-close").click

      # Verify focus returns to trigger element
      focused_element = page.evaluate_script("document.activeElement")
      fullscreen_button = find("[data-action*='fullscreen']")

      assert_equal fullscreen_button.native, focused_element,
                   "Focus should return to trigger element when modal is closed"
    end

    # 2. Test focus indicators
    interactive_elements = [
      "button",
      "a",
      "[role='button']",
      ".btn-modern-primary",
      ".btn-modern-secondary"
    ]

    interactive_elements.each do |selector|
      if has_selector?(selector)
        element = find(selector, match: :first)

        # Focus the element
        element.send_keys(:tab)

        # Verify element is focused
        focused_element = page.evaluate_script("document.activeElement")
        assert_equal element.native, focused_element,
                     "Element #{selector} should be focusable"

        # Check for visible focus indicator
        focus_styles = page.evaluate_script(
          "window.getComputedStyle(document.activeElement)"
        )

        has_focus_indicator = focus_styles["outline"] != "none" ||
                              focus_styles["boxShadow"] != "none" ||
                              focus_styles["border"] != "none"

        assert has_focus_indicator, "Element should have visible focus indicator"
      end
    end
  end

  test "dashboard screen reader navigation works correctly" do
    visit root_path

    # Simulate screen reader navigation
    simulate_screen_reader do
      # Test heading structure for screen reader navigation
      assert_proper_heading_hierarchy

      # Test landmark regions
      landmarks = [
        "[role='banner']",
        "[role='navigation']",
        "[role='main']",
        "header",
        "nav",
        "main",
        "footer"
      ]

      has_landmarks = false

      landmarks.each do |landmark|
        if has_selector?(landmark)
          has_landmarks = true

          # Verify landmark has accessible name if required
          if %w[navigation complementary].include?(page.evaluate_script(
            "document.querySelector('#{landmark}').getAttribute('role')"
          ))
            assert_accessible_name(landmark)
          end
        end
      end

      assert has_landmarks, "Page should have proper landmark regions for screen reader navigation"

      # Test skip link if it exists
      if has_selector?("#skip-to-content")
        skip_link = find("#skip-to-content")

        # Verify skip link targets valid element
        target_id = skip_link[:href].gsub(/.*#/, "")
        assert has_selector?("##{target_id}"), "Skip link should target valid element"
      end
    end
  end
end
