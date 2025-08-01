require "application_system_test_case"

class ResponsiveTransactionsTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "transaction list is responsive and adapts to different screen sizes" do
    visit transactions_path

    # Test at different viewport sizes
    UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports].each do |name, dimensions|
      with_viewport(*dimensions) do
        # Verify transaction list renders at this viewport
        assert_selector ".responsive-transaction-list"

        # Check for responsive layout adjustments
        case name
        when :mobile
          # Mobile layout checks
          assert_no_selector ".hidden-mobile", visible: true
          assert_selector ".md\\:hidden", visible: true

          # Check for stacked layout
          if has_selector?(".responsive-transaction-item", count: 2)
            items = all(".responsive-transaction-item")
            item1 = items[0]
            item2 = items[1]

            item1_rect = page.evaluate_script(
              "arguments[0].getBoundingClientRect()",
              item1.native
            )

            item2_rect = page.evaluate_script(
              "arguments[0].getBoundingClientRect()",
              item2.native
            )

            # Items should be stacked vertically
            assert item2_rect["top"] > item1_rect["bottom"],
                   "Transaction items should be stacked vertically on mobile"
          end

        when :tablet
          # Tablet layout checks
          assert_selector ".hidden-mobile", visible: true
          assert_no_selector ".lg\\:block", visible: true

        when :desktop
          # Desktop layout checks
          assert_selector ".hidden-mobile", visible: true
          assert_selector ".lg\\:block", visible: true
        end

        # Take screenshot for visual reference
        take_component_screenshot("responsive_transactions_#{name}", theme: current_theme)
      end
    end
  end

  test "transaction filters are touch-friendly and responsive" do
    visit transactions_path

    # Test at different viewport sizes
    UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports].each do |name, dimensions|
      with_viewport(*dimensions) do
        # Verify filters render at this viewport
        assert_selector ".responsive-transaction-filters"

        # Check for responsive layout adjustments
        case name
        when :mobile
          # Mobile layout checks - filters should be stacked
          search_input = find(".responsive-transaction-filters input[type='search']")
          filter_button = find(".responsive-transaction-filters button", text: "Filters")

          search_rect = page.evaluate_script(
            "arguments[0].getBoundingClientRect()",
            search_input.native
          )

          filter_rect = page.evaluate_script(
            "arguments[0].getBoundingClientRect()",
            filter_button.native
          )

          # Search should be above filters on mobile
          assert search_rect["bottom"] <= filter_rect["top"] ||
                 (search_rect["left"] < filter_rect["left"] && search_rect["right"] > filter_rect["left"]),
                 "Search input should be above or to the left of filter button on mobile"

        when :desktop
          # Desktop layout checks - filters should be side by side
          search_input = find(".responsive-transaction-filters input[type='search']")
          filter_button = find(".responsive-transaction-filters button", text: "Filters")

          search_rect = page.evaluate_script(
            "arguments[0].getBoundingClientRect()",
            search_input.native
          )

          filter_rect = page.evaluate_script(
            "arguments[0].getBoundingClientRect()",
            filter_button.native
          )

          # Search should be to the left of filters on desktop
          assert search_rect["right"] < filter_rect["left"],
                 "Search input should be to the left of filter button on desktop"
        end

        # Check touch target sizes on mobile
        if name == :mobile
          # Buttons should have adequate touch target size
          filter_button = find(".responsive-transaction-filters button", text: "Filters")

          button_height = page.evaluate_script(
            "arguments[0].getBoundingClientRect().height",
            filter_button.native
          )

          assert button_height >= 40, "Touch targets should be at least 40px tall on mobile"
        end
      end
    end
  end

  test "transaction pagination is responsive and touch-friendly" do
    # Create enough transactions to trigger pagination
    create_multiple_transactions(30)

    visit transactions_path

    # Test at different viewport sizes
    UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports].each do |name, dimensions|
      with_viewport(*dimensions) do
        # Verify pagination renders at this viewport
        assert_selector "nav[aria-label='Pagination']"

        # Check for responsive layout adjustments
        case name
        when :mobile
          # Mobile layout checks - simplified pagination
          assert_selector ".sm\\:hidden", visible: true
          assert_no_selector ".hidden.sm\\:flex", visible: true

          # Check for prev/next buttons
          assert has_link?("Previous") || has_text?("Previous")
          assert has_link?("Next") || has_text?("Next")

        when :desktop
          # Desktop layout checks - full pagination
          assert_no_selector ".sm\\:hidden", visible: true
          assert_selector ".hidden.sm\\:flex", visible: true

          # Check for page numbers
          assert_selector "nav[aria-label='Pagination'] a, nav[aria-label='Pagination'] span", minimum: 3
        end

        # Check touch target sizes on mobile
        if name == :mobile
          # Pagination links should have adequate touch target size
          if has_link?("Next")
            next_link = find("a", text: "Next")

            link_height = page.evaluate_script(
              "arguments[0].getBoundingClientRect().height",
              next_link.native
            )

            assert link_height >= 40, "Pagination links should be at least 40px tall on mobile"
          end
        end
      end
    end
  end

  test "transaction items have proper column prioritization on small screens" do
    visit transactions_path

    # Test at different viewport sizes
    UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports].each do |name, dimensions|
      with_viewport(*dimensions) do
        # Skip if no transaction items
        next unless has_selector?(".responsive-transaction-item")

        # Get first transaction item
        item = find(".responsive-transaction-item", match: :first)

        # Check for column visibility based on screen size
        case name
        when :mobile
          # On mobile, only name and amount should be visible
          assert item.has_selector?(".col-span-8")
          assert item.has_selector?(".col-span-4")
          assert item.has_no_selector?(".hidden.lg\\:block", visible: true)

          # Category should be below name on mobile
          assert item.has_selector?(".block.md\\:hidden")

        when :tablet
          # On tablet, name, category, and amount should be visible
          assert item.has_selector?(".md\\:col-span-6")
          assert item.has_selector?(".hidden.md\\:flex")
          assert item.has_selector?(".md\\:col-span-4")
          assert item.has_no_selector?(".hidden.lg\\:block", visible: true)

        when :desktop
          # On desktop, all columns should be visible
          assert item.has_selector?(".lg\\:col-span-6, .lg\\:col-span-8")
          assert item.has_selector?(".hidden.lg\\:block", visible: true)
        end
      end
    end
  end

  test "transaction items have touch-friendly interactions on mobile" do
    visit transactions_path

    # Test on mobile viewport
    with_viewport(*UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports][:mobile]) do
      # Skip if no transaction items
      skip "No transaction items found" unless has_selector?(".responsive-transaction-item")

      # Get first transaction item
      item = find(".responsive-transaction-item", match: :first)

      # Check for touch-friendly attributes
      assert_includes item[:class], "touch-manipulation"

      # Check checkbox size
      if item.has_selector?("input[type='checkbox']")
        checkbox = item.find("input[type='checkbox']")

        checkbox_size = page.evaluate_script(
          "window.getComputedStyle(arguments[0]).width",
          checkbox.native
        )

        # Convert to number and check size
        checkbox_size = checkbox_size.to_s.gsub("px", "").to_f
        assert checkbox_size >= 20, "Checkbox should be at least 20px wide on mobile"
      end

      # Check link target size
      if item.has_selector?("a")
        link = item.find("a", match: :first)

        link_height = page.evaluate_script(
          "arguments[0].getBoundingClientRect().height",
          link.native
        )

        assert link_height >= 32, "Link targets should be at least 32px tall on mobile"
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
end
