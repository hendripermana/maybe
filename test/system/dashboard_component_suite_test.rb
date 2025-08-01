require "application_system_test_case"

class DashboardComponentSuiteTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "dashboard card components render correctly and are theme-aware" do
    visit root_path

    # Verify dashboard cards exist
    assert_selector ".dashboard-card", minimum: 1

    # Test cards in both themes
    test_both_themes do
      cards = all(".dashboard-card")

      cards.each do |card|
        # Check for theme awareness
        assert_no_hardcoded_colors(card)

        # Check for proper structure
        assert card.has_selector?(".card-title"), "Card should have a title"
        assert card.has_selector?(".card-content"), "Card should have content"

        # Check for proper CSS variables
        card_bg = page.evaluate_script(
          "getComputedStyle(arguments[0]).backgroundColor",
          card.native
        )

        # Verify card uses theme variables
        if current_theme == "light"
          refute_equal "rgb(0, 0, 0)", card_bg, "Card should not have black background in light theme"
        else
          refute_equal "rgb(255, 255, 255)", card_bg, "Card should not have white background in dark theme"
        end
      end
    end
  end

  test "dashboard chart containers are responsive and theme-aware" do
    visit root_path

    # Verify chart containers exist
    assert_selector ".chart-container", minimum: 1

    # Test chart containers in both themes
    test_both_themes do
      charts = all(".chart-container")

      charts.each do |chart|
        # Check for theme awareness
        assert_no_hardcoded_colors(chart)

        # Check for responsive attributes
        assert chart[:class].include?("w-full"), "Chart container should be full width"

        # Check for proper overflow handling
        chart_overflow = page.evaluate_script(
          "getComputedStyle(arguments[0]).overflow",
          chart.native
        )

        assert [ "hidden", "auto", "scroll" ].include?(chart_overflow),
               "Chart container should handle overflow properly"
      end

      # Test responsiveness at different viewport sizes
      UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports].each do |name, dimensions|
        with_viewport(*dimensions) do
          assert_selector ".chart-container", minimum: 1

          # Check that charts adjust to viewport
          chart_width = page.evaluate_script(
            "document.querySelector('.chart-container').offsetWidth"
          )

          # Chart should be smaller than viewport width
          assert chart_width <= dimensions[0],
                 "Chart should fit within viewport width (#{name})"
        end
      end
    end
  end

  test "dashboard buttons are properly styled and accessible" do
    visit root_path

    # Find all dashboard buttons
    buttons = all("button, .btn-modern-primary, .btn-modern-secondary")

    # Skip test if no buttons found
    skip "No buttons found on dashboard" if buttons.empty?

    # Test buttons in both themes
    test_both_themes do
      buttons.each do |button|
        # Check for theme awareness
        assert_no_hardcoded_colors(button)

        # Check for accessibility
        assert_accessible_name(button)
        assert_keyboard_navigable(button)

        # Check for proper focus styles
        button.send_keys(:tab)

        # Get focus styles
        focus_styles = page.evaluate_script(
          "window.getComputedStyle(document.activeElement)"
        )

        # Verify focus outline or ring
        has_focus_indicator = focus_styles["outline"] != "none" ||
                              focus_styles["boxShadow"] != "none" ||
                              focus_styles["border"] != "none"

        assert has_focus_indicator, "Button should have visible focus indicator"
      end
    end
  end

  test "dashboard layout is responsive and adapts to different screen sizes" do
    visit root_path

    # Test at different viewport sizes
    UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports].each do |name, dimensions|
      with_viewport(*dimensions) do
        # Verify dashboard renders at this viewport
        assert_selector ".dashboard-page"

        # Check for responsive layout adjustments
        case name
        when :mobile
          # Mobile layout checks
          assert_no_selector ".dashboard-sidebar", visible: true if has_selector?(".dashboard-sidebar", visible: false)
          assert_selector ".mobile-menu-button", visible: true if has_selector?(".mobile-menu-button", count: 0)

          # Check for stacked layout
          cards = all(".dashboard-card")
          if cards.length >= 2
            card1 = cards[0]
            card2 = cards[1]

            card1_rect = page.evaluate_script(
              "arguments[0].getBoundingClientRect()",
              card1.native
            )

            card2_rect = page.evaluate_script(
              "arguments[0].getBoundingClientRect()",
              card2.native
            )

            # Cards should be stacked vertically on mobile
            assert card2_rect["top"] > card1_rect["bottom"],
                   "Cards should be stacked vertically on mobile"
          end

        when :desktop
          # Desktop layout checks
          assert_selector ".dashboard-sidebar", visible: true if has_selector?(".dashboard-sidebar", count: 0)
          assert_no_selector ".mobile-menu-button", visible: true if has_selector?(".mobile-menu-button", visible: false)

          # Check for grid layout
          if has_selector?(".dashboard-grid")
            grid_display = page.evaluate_script(
              "getComputedStyle(document.querySelector('.dashboard-grid')).display"
            )

            assert [ "grid", "flex" ].include?(grid_display),
                   "Dashboard should use grid or flex layout on desktop"
          end
        end

        # Take screenshot for visual reference
        take_component_screenshot("dashboard_responsive_#{name}", theme: current_theme)
      end
    end
  end

  test "dashboard fullscreen modal works correctly" do
    visit root_path

    # Skip if no fullscreen button exists
    skip "No fullscreen button found" unless has_selector?("[data-action*='fullscreen']")

    # Test fullscreen modal in both themes
    test_both_themes do
      # Click fullscreen button
      find("[data-action*='fullscreen']").click

      # Verify modal appears
      assert_selector ".modal-fullscreen", visible: true

      # Check modal is theme-aware
      assert_no_hardcoded_colors(".modal-fullscreen")

      # Check modal is accessible
      modal = find(".modal-fullscreen")
      assert modal["role"] == "dialog", "Modal should have dialog role"
      assert modal["aria-modal"] == "true", "Modal should have aria-modal attribute"

      # Check for proper focus management
      focused_element = page.evaluate_script("document.activeElement")
      assert_equal modal.native, focused_element, "Modal should receive focus when opened"

      # Check for close button
      assert_selector ".modal-close", visible: true

      # Close modal
      find(".modal-close").click

      # Verify modal closed
      assert_no_selector ".modal-fullscreen", visible: true
    end
  end

  test "dashboard sankey chart renders correctly in both themes" do
    visit root_path

    # Skip if no sankey chart exists
    skip "No sankey chart found" unless has_selector?("#sankey-chart")

    # Test sankey chart in both themes
    test_both_themes do
      # Verify chart elements
      assert_selector "#sankey-chart .node rect"
      assert_selector "#sankey-chart .link"

      # Check for theme-specific colors
      nodes = all("#sankey-chart .node rect")

      nodes.each do |node|
        # Check for theme awareness
        fill_color = page.evaluate_script(
          "arguments[0].getAttribute('fill')",
          node.native
        )

        # Verify node colors are not hardcoded
        refute [ "#ffffff", "#000000", "white", "black" ].include?(fill_color&.downcase),
               "Sankey chart nodes should not use hardcoded colors"
      end

      # Check for proper labels
      assert_selector "#sankey-chart .node text"

      # Check label contrast
      labels = all("#sankey-chart .node text")

      labels.each do |label|
        # Get label color
        label_color = page.evaluate_script(
          "arguments[0].getAttribute('fill') || getComputedStyle(arguments[0]).fill",
          label.native
        )

        # Verify label colors are not hardcoded
        refute [ "#ffffff", "#000000", "white", "black" ].include?(label_color&.downcase),
               "Sankey chart labels should not use hardcoded colors"
      end
    end
  end

  test "dashboard visual regression across themes and viewports" do
    visit root_path

    # Take screenshots in both themes across different viewports
    UiTestingConfig::THEME_CONFIG[:themes].each do |theme|
      with_theme(theme) do
        UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports].each do |name, dimensions|
          with_viewport(*dimensions) do
            # Take screenshot of entire dashboard
            take_component_screenshot("dashboard_full_#{name}", theme: theme)

            # Take screenshots of individual components if they exist
            if has_selector?(".dashboard-card")
              take_component_screenshot("dashboard_card_#{name}", theme: theme)
            end

            if has_selector?(".chart-container")
              take_component_screenshot("dashboard_chart_#{name}", theme: theme)
            end

            if has_selector?("#sankey-chart")
              take_component_screenshot("dashboard_sankey_#{name}", theme: theme)
            end
          end
        end
      end
    end
  end
end
