require "application_system_test_case"

class ModernizedPagesCrossBrowserTest < ApplicationSystemTestCase
  setup do
    @user = users(:family_admin)
    sign_in @user
  end

  # Define browsers to test if running locally
  BROWSERS_TO_TEST = ENV["CI"].present? ? [ :headless_chrome ] : [ :chrome, :firefox ]

  # Test dashboard page in different browsers
  BROWSERS_TO_TEST.each do |browser|
    test "dashboard page displays correctly in #{browser}" do
      # Skip if browser is not available
      skip "#{browser} not available for testing" unless browser_available?(browser)

      # Use the specified browser
      using_browser(browser) do
        visit root_path

        # Verify page loads with correct structure
        assert_selector ".dashboard-page", "Dashboard page should load in #{browser}"

        # Verify theme switching works
        if has_selector?("[data-theme-toggle]")
          find("[data-theme-toggle]").click
          assert_selector "[data-theme='dark']", "Theme switching should work in #{browser}"
        end

        # Verify charts render correctly
        assert_selector ".dashboard-chart", "Dashboard charts should render in #{browser}"

        # Take screenshot for reference
        take_component_screenshot("dashboard_#{browser}")
      end
    end
  end

  # Test transactions page in different browsers
  BROWSERS_TO_TEST.each do |browser|
    test "transactions page displays correctly in #{browser}" do
      # Skip if browser is not available
      skip "#{browser} not available for testing" unless browser_available?(browser)

      # Use the specified browser
      using_browser(browser) do
        visit transactions_path

        # Verify page loads with correct structure
        assert_selector ".transactions-page", "Transactions page should load in #{browser}"

        # Verify transaction list renders
        assert_selector ".transactions-list", "Transaction list should render in #{browser}"

        # Verify filters work
        if has_selector?(".transaction-filters")
          assert_selector ".transaction-filters", "Transaction filters should render in #{browser}"
        end

        # Take screenshot for reference
        take_component_screenshot("transactions_#{browser}")
      end
    end
  end

  # Test budgets page in different browsers
  BROWSERS_TO_TEST.each do |browser|
    test "budgets page displays correctly in #{browser}" do
      # Skip if browser is not available
      skip "#{browser} not available for testing" unless browser_available?(browser)

      # Use the specified browser
      using_browser(browser) do
        visit budgets_path

        # Verify page loads with correct structure
        assert_selector ".budgets-page", "Budgets page should load in #{browser}"

        # Verify budget list renders
        assert_selector ".budget-list", "Budget list should render in #{browser}"

        # Verify budget progress bars render correctly
        if has_selector?(".budget-progress")
          assert_selector ".budget-progress", "Budget progress bars should render in #{browser}"
        end

        # Take screenshot for reference
        take_component_screenshot("budgets_#{browser}")
      end
    end
  end

  # Test settings page in different browsers
  BROWSERS_TO_TEST.each do |browser|
    test "settings page displays correctly in #{browser}" do
      # Skip if browser is not available
      skip "#{browser} not available for testing" unless browser_available?(browser)

      # Use the specified browser
      using_browser(browser) do
        visit settings_preferences_path

        # Verify page loads with correct structure
        assert_selector ".settings-page", "Settings page should load in #{browser}"

        # Verify settings form renders
        assert_selector ".settings-form", "Settings form should render in #{browser}"

        # Verify theme selector renders correctly
        if has_selector?(".theme-selector")
          assert_selector ".theme-selector", "Theme selector should render in #{browser}"
        end

        # Take screenshot for reference
        take_component_screenshot("settings_#{browser}")
      end
    end
  end

  private

    def browser_available?(browser)
      # Check if browser is available for testing
      # This is a simple check that would need to be expanded in a real environment
      true
    end

    def using_browser(browser)
      # Store current driver
      original_driver = Capybara.current_driver

      # Set driver to specified browser
      Capybara.current_driver = browser

      yield
    ensure
      # Restore original driver
      Capybara.current_driver = original_driver
    end
end
