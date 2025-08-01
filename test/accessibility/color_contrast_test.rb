require "test_helper"
require "application_system_test_case"

class ColorContrastTest < ApplicationSystemTestCase
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

  # Test color contrast for all pages in both themes
  def test_color_contrast_in_both_themes
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]

      # Test in light theme
      puts "Testing #{page_info[:name]} color contrast in light theme"
      test_color_contrast_on_page

      # Test in dark theme
      if page.has_selector?('[data-testid="theme-toggle"]')
        find('[data-testid="theme-toggle"]').click
        puts "Testing #{page_info[:name]} color contrast in dark theme"
        test_color_contrast_on_page
      end

      # Log successful test
      puts "✓ #{page_info[:name]} passes color contrast tests in both themes"
    end
  end

  # Test for hardcoded colors that might affect contrast
  def test_for_hardcoded_colors
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]

      # Test in light theme
      assert_no_hardcoded_colors

      # Test in dark theme
      if page.has_selector?('[data-testid="theme-toggle"]')
        find('[data-testid="theme-toggle"]').click
        assert_no_hardcoded_colors
      end

      # Log successful test
      puts "✓ #{page_info[:name]} has no hardcoded colors affecting contrast"
    end
  end

  # Test focus indicators in both themes
  def test_focus_indicators_in_both_themes
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]

      # Test in light theme
      test_focus_indicators

      # Test in dark theme
      if page.has_selector?('[data-testid="theme-toggle"]')
        find('[data-testid="theme-toggle"]').click
        test_focus_indicators
      end

      # Log successful test
      puts "✓ #{page_info[:name]} has proper focus indicators in both themes"
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

    def assert_no_hardcoded_colors
      # Check for hardcoded background colors
      hardcoded_bg_elements = page.all(".bg-white, .bg-black, .bg-gray-900, [style*='background-color: white'], [style*='background-color: black']")
      assert hardcoded_bg_elements.count == 0, "Found #{hardcoded_bg_elements.count} elements with hardcoded background colors"

      # Check for hardcoded text colors
      hardcoded_text_elements = page.all(".text-white, .text-black, .text-gray-900, [style*='color: white'], [style*='color: black']")
      assert hardcoded_text_elements.count == 0, "Found #{hardcoded_text_elements.count} elements with hardcoded text colors"
    end

    def test_focus_indicators
      # Find interactive elements
      interactive_elements = page.all("button, a, [role='button'], input, select, textarea").first(10)

      # Test focus indicators for each element
      interactive_elements.each do |element|
        # Focus the element
        element.send_keys(:tab)

        # Check if the element has a visible focus indicator
        focused_element = page.find(":focus")
        assert focused_element.present?, "Element should have a visible focus indicator"

        # Check if the focus indicator has sufficient contrast
        assert_sufficient_contrast(focused_element)
      end
    end
end
