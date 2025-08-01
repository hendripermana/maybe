require "application_system_test_case"

class ModernizedPagesResponsiveTest < ApplicationSystemTestCase
  setup do
    @user = users(:family_admin)
    sign_in @user
  end

  # Define viewport sizes to test
  VIEWPORT_SIZES = {
    mobile: [ 375, 667 ],
    tablet: [ 768, 1024 ],
    desktop: [ 1280, 800 ],
    large_desktop: [ 1920, 1080 ]
  }

  # Test dashboard page responsiveness
  test "dashboard page is responsive across all device sizes" do
    # Test at different viewport sizes
    VIEWPORT_SIZES.each do |device, dimensions|
      with_viewport(*dimensions) do
        visit root_path

        # Verify page loads with correct structure
        assert_selector ".dashboard-page", "Dashboard page should load on #{device}"

        # Check for responsive layout adjustments
        case device
        when :mobile
          # Mobile layout checks
          assert_selector ".sm\\:hidden", visible: true
          assert_no_selector ".hidden.sm\\:block", visible: true

          # Check for stacked layout
          cards = all(".dashboard-card")
          if cards.size >= 2
            card1_rect = page.evaluate_script(
              "arguments[0].getBoundingClientRect()",
              cards[0].native
            )

            card2_rect = page.evaluate_script(
              "arguments[0].getBoundingClientRect()",
              cards[1].native
            )

            # Cards should be stacked vertically or side by side
            assert(card2_rect["top"] >= card1_rect["bottom"] ||
                   card2_rect["left"] >= card1_rect["right"],
                   "Dashboard cards should be properly arranged on mobile")
          end

        when :tablet
          # Tablet layout checks
          assert_no_selector ".sm\\:hidden", visible: true
          assert_selector ".hidden.sm\\:block", visible: true
          assert_selector ".md\\:grid-cols-2", visible: true

        when :desktop, :large_desktop
          # Desktop layout checks
          assert_no_selector ".sm\\:hidden", visible: true
          assert_selector ".hidden.sm\\:block", visible: true
          assert_selector ".lg\\:grid-cols-3", visible: true
        end

        # Take screenshot for reference
        take_component_screenshot("dashboard_responsive_#{device}")
      end
    end
  end

  # Test transactions page responsiveness
  test "transactions page is responsive across all device sizes" do
    # Test at different viewport sizes
    VIEWPORT_SIZES.each do |device, dimensions|
      with_viewport(*dimensions) do
        visit transactions_path

        # Verify page loads with correct structure
        assert_selector ".transactions-page", "Transactions page should load on #{device}"

        # Check for responsive layout adjustments
        case device
        when :mobile
          # Mobile layout checks
          assert_selector ".sm\\:hidden", visible: true
          assert_no_selector ".hidden.sm\\:block", visible: true

          # Check for mobile-optimized transaction list
          if has_selector?(".transaction-item")
            # Check that transaction items have appropriate mobile styling
            transaction_item = find(".transaction-item", match: :first)

            # Check that touch targets are large enough
            item_height = page.evaluate_script(
              "arguments[0].getBoundingClientRect().height",
              transaction_item.native
            )

            assert item_height >= 48, "Transaction items should have adequate touch target size on mobile"
          end

        when :tablet
          # Tablet layout checks
          assert_no_selector ".sm\\:hidden", visible: true
          assert_selector ".hidden.sm\\:block", visible: true

        when :desktop, :large_desktop
          # Desktop layout checks
          assert_no_selector ".sm\\:hidden", visible: true
          assert_selector ".hidden.sm\\:block", visible: true
          assert_selector ".lg\\:grid-cols-1", visible: true
        end

        # Take screenshot for reference
        take_component_screenshot("transactions_responsive_#{device}")
      end
    end
  end

  # Test budgets page responsiveness
  test "budgets page is responsive across all device sizes" do
    # Test at different viewport sizes
    VIEWPORT_SIZES.each do |device, dimensions|
      with_viewport(*dimensions) do
        visit budgets_path

        # Verify page loads with correct structure
        assert_selector ".budgets-page", "Budgets page should load on #{device}"

        # Check for responsive layout adjustments
        case device
        when :mobile
          # Mobile layout checks
          assert_selector ".sm\\:hidden", visible: true
          assert_no_selector ".hidden.sm\\:block", visible: true

          # Check for mobile-optimized budget cards
          if has_selector?(".budget-card")
            # Check that budget cards have appropriate mobile styling
            budget_card = find(".budget-card", match: :first)

            # Check that touch targets are large enough
            card_height = page.evaluate_script(
              "arguments[0].getBoundingClientRect().height",
              budget_card.native
            )

            assert card_height >= 100, "Budget cards should have adequate size on mobile"
          end

        when :tablet
          # Tablet layout checks
          assert_no_selector ".sm\\:hidden", visible: true
          assert_selector ".hidden.sm\\:block", visible: true
          assert_selector ".md\\:grid-cols-2", visible: true

        when :desktop, :large_desktop
          # Desktop layout checks
          assert_no_selector ".sm\\:hidden", visible: true
          assert_selector ".hidden.sm\\:block", visible: true
          assert_selector ".lg\\:grid-cols-3", visible: true
        end

        # Take screenshot for reference
        take_component_screenshot("budgets_responsive_#{device}")
      end
    end
  end

  # Test settings page responsiveness
  test "settings page is responsive across all device sizes" do
    # Test at different viewport sizes
    VIEWPORT_SIZES.each do |device, dimensions|
      with_viewport(*dimensions) do
        visit settings_preferences_path

        # Verify page loads with correct structure
        assert_selector ".settings-page", "Settings page should load on #{device}"

        # Check for responsive layout adjustments
        case device
        when :mobile
          # Mobile layout checks
          assert_selector ".sm\\:hidden", visible: true
          assert_no_selector ".hidden.sm\\:block", visible: true

          # Check for stacked layout
          if has_selector?(".settings-sidebar") && has_selector?(".settings-content")
            sidebar_rect = page.evaluate_script(
              "arguments[0].getBoundingClientRect()",
              find(".settings-sidebar").native
            )

            content_rect = page.evaluate_script(
              "arguments[0].getBoundingClientRect()",
              find(".settings-content").native
            )

            # Sidebar should be above content on mobile
            assert sidebar_rect["bottom"] <= content_rect["top"] ||
                   sidebar_rect["right"] <= content_rect["left"],
                   "Settings sidebar should be above or to the left of content on mobile"
          end

        when :tablet
          # Tablet layout checks
          assert_no_selector ".sm\\:hidden", visible: true
          assert_selector ".hidden.sm\\:block", visible: true

        when :desktop, :large_desktop
          # Desktop layout checks
          assert_no_selector ".sm\\:hidden", visible: true
          assert_selector ".hidden.sm\\:block", visible: true

          # Check for side-by-side layout
          if has_selector?(".settings-sidebar") && has_selector?(".settings-content")
            sidebar_rect = page.evaluate_script(
              "arguments[0].getBoundingClientRect()",
              find(".settings-sidebar").native
            )

            content_rect = page.evaluate_script(
              "arguments[0].getBoundingClientRect()",
              find(".settings-content").native
            )

            # Sidebar should be to the left of content on desktop
            assert sidebar_rect["right"] <= content_rect["left"],
                   "Settings sidebar should be to the left of content on desktop"
          end
        end

        # Take screenshot for reference
        take_component_screenshot("settings_responsive_#{device}")
      end
    end
  end

  # Test touch interactions on mobile devices
  test "touch interactions work properly on mobile devices" do
    # Test on mobile viewport
    with_viewport(*VIEWPORT_SIZES[:mobile]) do
      # Test dashboard touch interactions
      visit root_path

      # Check for touch-friendly elements
      assert_touch_friendly_elements

      # Test transactions touch interactions
      visit transactions_path

      # Check for touch-friendly elements
      assert_touch_friendly_elements

      # Test budgets touch interactions
      visit budgets_path

      # Check for touch-friendly elements
      assert_touch_friendly_elements

      # Test settings touch interactions
      visit settings_preferences_path

      # Check for touch-friendly elements
      assert_touch_friendly_elements
    end
  end

  # Test orientation changes on mobile devices
  test "pages adapt to orientation changes on mobile devices" do
    # Test portrait orientation
    with_viewport(*VIEWPORT_SIZES[:mobile]) do
      # Test dashboard in portrait
      visit root_path
      take_component_screenshot("dashboard_portrait")

      # Test transactions in portrait
      visit transactions_path
      take_component_screenshot("transactions_portrait")

      # Test budgets in portrait
      visit budgets_path
      take_component_screenshot("budgets_portrait")

      # Test settings in portrait
      visit settings_preferences_path
      take_component_screenshot("settings_portrait")
    end

    # Test landscape orientation (swap width and height)
    landscape_dimensions = [ VIEWPORT_SIZES[:mobile][1], VIEWPORT_SIZES[:mobile][0] ]
    with_viewport(*landscape_dimensions) do
      # Test dashboard in landscape
      visit root_path
      take_component_screenshot("dashboard_landscape")

      # Test transactions in landscape
      visit transactions_path
      take_component_screenshot("transactions_landscape")

      # Test budgets in landscape
      visit budgets_path
      take_component_screenshot("budgets_landscape")

      # Test settings in landscape
      visit settings_preferences_path
      take_component_screenshot("settings_landscape")
    end
  end

  private

    def assert_touch_friendly_elements
      # Check buttons for adequate touch target size
      all("button", visible: true).each do |button|
        button_rect = page.evaluate_script(
          "arguments[0].getBoundingClientRect()",
          button.native
        )

        # Buttons should be at least 44x44 pixels for touch targets
        assert button_rect["width"] >= 44, "Button width should be at least 44px for touch targets"
        assert button_rect["height"] >= 44, "Button height should be at least 44px for touch targets"
      end

      # Check links for adequate touch target size
      all("a", visible: true).each do |link|
        # Skip links that are just icons or have no text
        next if link.text.strip.empty?

        link_rect = page.evaluate_script(
          "arguments[0].getBoundingClientRect()",
          link.native
        )

        # Links should be at least 44px in one dimension for touch targets
        assert link_rect["width"] >= 44 || link_rect["height"] >= 44,
               "Link should have at least one dimension of 44px for touch targets"
      end

      # Check for proper spacing between interactive elements
      interactive_elements = all("button, a, input[type='checkbox'], input[type='radio']", visible: true)

      interactive_elements.each_cons(2) do |el1, el2|
        el1_rect = page.evaluate_script(
          "arguments[0].getBoundingClientRect()",
          el1.native
        )

        el2_rect = page.evaluate_script(
          "arguments[0].getBoundingClientRect()",
          el2.native
        )

        # Calculate horizontal and vertical spacing
        horizontal_spacing = [ 0, [ el2_rect["left"] - el1_rect["right"], el1_rect["left"] - el2_rect["right"] ].max ].max
        vertical_spacing = [ 0, [ el2_rect["top"] - el1_rect["bottom"], el1_rect["top"] - el2_rect["bottom"] ].max ].max

        # Elements should have adequate spacing if they're adjacent
        if horizontal_spacing < 100 && vertical_spacing < 100 # Only check nearby elements
          assert horizontal_spacing >= 8 || vertical_spacing >= 8,
                 "Interactive elements should have adequate spacing for touch targets"
        end
      end
    end
end
