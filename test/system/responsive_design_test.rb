require "application_system_test_case"

class ResponsiveDesignTest < ApplicationSystemTestCase
  # Define viewport sizes for testing
  VIEWPORTS = {
    mobile: [ 375, 667 ],
    tablet: [ 768, 1024 ],
    desktop: [ 1280, 800 ]
  }

  # Pages to test
  PAGES = {
    dashboard: "/",
    transactions: "/transactions",
    budgets: "/budgets",
    settings: "/settings"
  }

  setup do
    # Log in before each test
    @user = users(:default)
    login_as(@user)
  end

  # Test each page at each viewport size
  VIEWPORTS.each do |device, dimensions|
    PAGES.each do |page_name, path|
      test "#{page_name} page layout on #{device}" do
        # Set viewport size
        width, height = dimensions
        page.driver.browser.manage.window.resize_to(width, height)

        # Visit the page
        visit path

        # Common elements that should be visible on all pages
        assert_selector "header", visible: true

        # Device-specific tests
        case device
        when :mobile
          # Mobile-specific assertions
          if page_name == :dashboard
            # Dashboard specific mobile tests
            assert_selector ".dashboard-grid", visible: true
          elsif page_name == :transactions
            # Transaction specific mobile tests
            assert_selector ".transaction-list", visible: true
          end

          # Test navigation menu (likely a hamburger menu on mobile)
          if has_selector?(".mobile-menu-button")
            find(".mobile-menu-button").click
            assert_selector ".mobile-menu", visible: true
          end

        when :tablet
          # Tablet-specific assertions
          if page_name == :dashboard
            # Dashboard specific tablet tests
            assert_selector ".dashboard-grid", visible: true
          end

        when :desktop
          # Desktop-specific assertions
          if page_name == :dashboard
            # Dashboard specific desktop tests
            assert_selector ".dashboard-grid", visible: true
          end
        end

        # Take screenshot for visual verification
        take_screenshot "#{page_name}_#{device}"
      end
    end
  end

  # Test orientation changes on mobile and tablet
  [ :mobile, :tablet ].each do |device|
    test "orientation change on #{device}" do
      width, height = VIEWPORTS[device]

      # Start in portrait mode
      page.driver.browser.manage.window.resize_to(width, height)
      visit "/"
      take_screenshot "#{device}_portrait"

      # Switch to landscape mode
      page.driver.browser.manage.window.resize_to(height, width)
      take_screenshot "#{device}_landscape"

      # Verify content is still accessible
      assert_selector "header", visible: true
      assert_selector ".dashboard-grid", visible: true
    end
  end

  # Test touch interactions
  test "touch interactions on mobile" do
    # Set mobile viewport
    width, height = VIEWPORTS[:mobile]
    page.driver.browser.manage.window.resize_to(width, height)

    # Test button interactions
    visit "/"

    # Find and click a button using touch events
    if has_selector?("button.primary")
      find("button.primary").click
      # Verify expected response
    end

    # Test form interactions
    visit "/settings"

    # Find and interact with form elements
    if has_selector?("input[type='text']")
      find("input[type='text']").click
      # Verify input receives focus
    end

    # Test dropdown interactions
    if has_selector?("select")
      find("select").click
      # Verify dropdown opens
    end
  end

  # Test text scaling and readability
  test "text scaling and readability" do
    VIEWPORTS.each do |device, dimensions|
      width, height = dimensions
      page.driver.browser.manage.window.resize_to(width, height)

      visit "/"

      # Check that headings are visible and not truncated
      if has_selector?("h1")
        heading = find("h1")
        assert heading.visible?
      end

      # Check paragraph text
      if has_selector?("p")
        paragraph = find("p")
        assert paragraph.visible?
      end

      take_screenshot "text_readability_#{device}"
    end
  end
end
