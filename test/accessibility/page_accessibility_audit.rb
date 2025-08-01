require "test_helper"
require "application_system_test_case"

class PageAccessibilityAudit < ApplicationSystemTestCase
  include AccessibilityTestHelper

  # List of main pages to test
  PAGES_TO_TEST = [
    { name: "Dashboard", path: "/" },
    { name: "Transactions", path: "/transactions" },
    { name: "Budgets", path: "/budgets" },
    { name: "Settings", path: "/settings/preferences" }
  ]

  setup do
    sign_in users(:family_admin)
  end

  # Test each page for accessibility in both themes
  def test_page_accessibility
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]

      # Test in light theme
      puts "Testing #{page_info[:name]} in light theme"
      assert_no_accessibility_violations

      # Test in dark theme
      if page.has_selector?('[data-testid="theme-toggle"]')
        find('[data-testid="theme-toggle"]').click
        puts "Testing #{page_info[:name]} in dark theme"
        assert_no_accessibility_violations
      end

      # Log successful test
      puts "✓ #{page_info[:name]} passes accessibility tests"
    end
  end

  # Test heading hierarchy for all pages
  def test_page_heading_hierarchy
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]

      # Test heading hierarchy
      assert_proper_heading_hierarchy

      # Log successful test
      puts "✓ #{page_info[:name]} passes heading hierarchy tests"
    end
  end

  # Test landmark regions for all pages
  def test_page_landmarks
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]

      # Test for main landmark
      assert page.has_selector?("main"), "Page should have a main landmark"

      # Test for navigation landmark
      assert page.has_selector?("nav"), "Page should have a navigation landmark"

      # Test for header landmark
      assert page.has_selector?("header"), "Page should have a header landmark"

      # Log successful test
      puts "✓ #{page_info[:name]} passes landmark tests"
    end
  end

  # Test keyboard navigation for all pages
  def test_page_keyboard_navigation
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]

      # Find all interactive elements
      interactive_elements = page.all("button, a, [role='button'], input, select, textarea, [tabindex='0']").first(10)

      # Test keyboard navigation
      interactive_elements.each do |element|
        assert_keyboard_navigable(element)
      end

      # Log successful test
      puts "✓ #{page_info[:name]} passes keyboard navigation tests"
    end
  end

  # Test color contrast for all pages
  def test_page_color_contrast
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]

      # Test in light theme
      test_color_contrast_on_page

      # Test in dark theme
      if page.has_selector?('[data-testid="theme-toggle"]')
        find('[data-testid="theme-toggle"]').click
        test_color_contrast_on_page
      end

      # Log successful test
      puts "✓ #{page_info[:name]} passes color contrast tests"
    end
  end

  # Test focus management for all pages
  def test_page_focus_management
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]

      # Test tab navigation through the page
      send_keys :tab
      assert page.has_selector?(":focus"), "Focus should be visible after tabbing"

      # Continue tabbing through the page
      10.times do
        send_keys :tab
        assert page.has_selector?(":focus"), "Focus should be visible after tabbing"
      end

      # Log successful test
      puts "✓ #{page_info[:name]} passes focus management tests"
    end
  end

  private

    def test_color_contrast_on_page
      # Find all text elements (limit to first 20 to avoid long tests)
      text_elements = page.all("p, h1, h2, h3, h4, h5, h6, span, a, button, label").first(20)

      # Test color contrast for each element
      text_elements.each do |element|
        begin
          assert_sufficient_contrast(element)
        rescue Minitest::Assertion => e
          puts "Color contrast issue in #{element.tag_name} with text: #{element.text.truncate(30)}"
          raise e
        end
      end
    end
end
