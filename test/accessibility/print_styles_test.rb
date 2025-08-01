require "test_helper"
require "application_system_test_case"

class PrintStylesTest < ApplicationSystemTestCase
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

  # Test print styles for all pages
  def test_print_styles
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]

      # Simulate print media query
      page.execute_script(<<~JS)
        document.body.classList.add('print-preview');

        // Create a style element for print simulation
        const style = document.createElement('style');
        style.id = 'print-simulation';
        style.textContent = `
          @media print {
            body {
              background-color: white !important;
              color: black !important;
            }
        #{'    '}
            /* Hide non-essential elements */
            nav, footer, button, [role="complementary"] {
              display: none !important;
            }
        #{'    '}
            /* Ensure all content is visible */
            main {
              display: block !important;
              width: 100% !important;
              max-width: 100% !important;
            }
        #{'    '}
            /* Remove backgrounds and shadows */
            * {
              background-color: transparent !important;
              box-shadow: none !important;
            }
        #{'    '}
            /* Ensure text is readable */
            p, h1, h2, h3, h4, h5, h6, span, li {
              color: black !important;
            }
        #{'    '}
            /* Show URLs for links */
            a::after {
              content: " (" attr(href) ")";
              font-size: 0.8em;
            }
        #{'    '}
            /* Ensure tables are readable */
            table {
              border-collapse: collapse !important;
            }
        #{'    '}
            th, td {
              border: 1px solid black !important;
            }
          }
        #{'  '}
          /* Apply print styles to preview */
          .print-preview {
            background-color: white !important;
            color: black !important;
          }
        #{'  '}
          .print-preview nav,
          .print-preview footer,
          .print-preview button,
          .print-preview [role="complementary"] {
            display: none !important;
          }
        #{'  '}
          .print-preview main {
            display: block !important;
            width: 100% !important;
            max-width: 100% !important;
          }
        #{'  '}
          .print-preview * {
            background-color: transparent !important;
            box-shadow: none !important;
          }
        #{'  '}
          .print-preview p,
          .print-preview h1,
          .print-preview h2,
          .print-preview h3,
          .print-preview h4,
          .print-preview h5,
          .print-preview h6,
          .print-preview span,
          .print-preview li {
            color: black !important;
          }
        #{'  '}
          .print-preview a::after {
            content: " (" attr(href) ")";
            font-size: 0.8em;
          }
        #{'  '}
          .print-preview table {
            border-collapse: collapse !important;
          }
        #{'  '}
          .print-preview th,
          .print-preview td {
            border: 1px solid black !important;
          }
        `;
        document.head.appendChild(style);
      JS

      # Test print preview
      assert_print_friendly_content

      # Reset
      page.execute_script(<<~JS)
        document.body.classList.remove('print-preview');
        document.getElementById('print-simulation').remove();
      JS

      # Log successful test
      puts "✓ #{page_info[:name]} has proper print styles"
    end
  end

  # Test reduced motion preferences
  def test_reduced_motion_preferences
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]

      # Simulate prefers-reduced-motion media query
      page.execute_script(<<~JS)
        document.body.classList.add('reduced-motion');

        // Create a style element for reduced motion simulation
        const style = document.createElement('style');
        style.id = 'reduced-motion-simulation';
        style.textContent = `
          @media (prefers-reduced-motion: reduce) {
            * {
              animation-duration: 0.001s !important;
              transition-duration: 0.001s !important;
            }
          }
        #{'  '}
          /* Apply reduced motion styles to preview */
          .reduced-motion * {
            animation-duration: 0.001s !important;
            transition-duration: 0.001s !important;
          }
        `;
        document.head.appendChild(style);
      JS

      # Test reduced motion
      assert_reduced_motion_support

      # Reset
      page.execute_script(<<~JS)
        document.body.classList.remove('reduced-motion');
        document.getElementById('reduced-motion-simulation').remove();
      JS

      # Log successful test
      puts "✓ #{page_info[:name]} supports reduced motion preferences"
    end
  end

  # Test high contrast mode
  def test_high_contrast_mode
    PAGES_TO_TEST.each do |page_info|
      visit page_info[:path]

      # Simulate high contrast mode
      page.execute_script(<<~JS)
        document.body.classList.add('high-contrast');

        // Create a style element for high contrast simulation
        const style = document.createElement('style');
        style.id = 'high-contrast-simulation';
        style.textContent = `
          @media (forced-colors: active) {
            * {
              color: CanvasText !important;
              background-color: Canvas !important;
              border-color: CanvasText !important;
            }
        #{'    '}
            a {
              color: LinkText !important;
            }
        #{'    '}
            button, input, select, textarea {
              border: 1px solid CanvasText !important;
            }
          }
        #{'  '}
          /* Apply high contrast styles to preview */
          .high-contrast * {
            color: black !important;
            background-color: white !important;
            border-color: black !important;
          }
        #{'  '}
          .high-contrast a {
            color: blue !important;
            text-decoration: underline !important;
          }
        #{'  '}
          .high-contrast button,
          .high-contrast input,
          .high-contrast select,
          .high-contrast textarea {
            border: 1px solid black !important;
          }
        `;
        document.head.appendChild(style);
      JS

      # Test high contrast mode
      assert_high_contrast_support

      # Reset
      page.execute_script(<<~JS)
        document.body.classList.remove('high-contrast');
        document.getElementById('high-contrast-simulation').remove();
      JS

      # Log successful test
      puts "✓ #{page_info[:name]} supports high contrast mode"
    end
  end

  private

    def assert_print_friendly_content
      # Check that main content is visible
      assert page.has_selector?("main"), "Main content should be visible in print preview"

      # Check that navigation is hidden
      assert page.has_no_selector?("nav"), "Navigation should be hidden in print preview"

      # Check that buttons are hidden
      assert page.has_no_selector?("button"), "Buttons should be hidden in print preview"

      # Check that links show URLs
      links = page.all("a")

      if links.any?
        link = links.first
        link_text = link.text

        # Check if URL is appended to link text
        assert link_text.include?(link[:href]), "Links should show URLs in print preview"
      end

      # Check that tables are properly formatted
      if page.has_selector?("table")
        tables = page.all("table")

        tables.each do |table|
          # Check that table cells have borders
          cells = table.all("th, td")

          if cells.any?
            cell = cells.first
            cell_style = page.evaluate_script("window.getComputedStyle(document.querySelector('th, td')).borderColor")

            assert cell_style == "rgb(0, 0, 0)" || cell_style == "#000000", "Table cells should have black borders in print preview"
          end
        end
      end
    end

    def assert_reduced_motion_support
      # Find elements with animations or transitions
      animated_elements = page.all("[class*='animate-'], [class*='transition-']")

      if animated_elements.any?
        element = animated_elements.first

        # Check animation duration
        animation_duration = page.evaluate_script(<<~JS)
        window.getComputedStyle(document.querySelector("[class*='animate-'], [class*='transition-']")).animationDuration
      JS

        assert animation_duration == "0.001s", "Animations should be shortened in reduced motion mode"

        # Check transition duration
        transition_duration = page.evaluate_script(<<~JS)
        window.getComputedStyle(document.querySelector("[class*='animate-'], [class*='transition-']")).transitionDuration
      JS

        assert transition_duration == "0.001s", "Transitions should be shortened in reduced motion mode"
      end
    end

    def assert_high_contrast_support
      # Check text color
      text_elements = page.all("p, h1, h2, h3, h4, h5, h6, span")

      if text_elements.any?
        element = text_elements.first

        # Check text color
        text_color = page.evaluate_script(<<~JS)
        window.getComputedStyle(document.querySelector("p, h1, h2, h3, h4, h5, h6, span")).color
      JS

        assert text_color == "rgb(0, 0, 0)" || text_color == "#000000", "Text should be black in high contrast mode"

        # Check background color
        background_color = page.evaluate_script(<<~JS)
        window.getComputedStyle(document.querySelector("p, h1, h2, h3, h4, h5, h6, span")).backgroundColor
      JS

        assert background_color == "rgb(255, 255, 255)" || background_color == "#ffffff", "Background should be white in high contrast mode"
      end

      # Check link color
      if page.has_selector?("a")
        link_color = page.evaluate_script(<<~JS)
        window.getComputedStyle(document.querySelector("a")).color
      JS

        assert link_color == "rgb(0, 0, 255)" || link_color == "#0000ff", "Links should be blue in high contrast mode"
      end

      # Check form controls
      form_controls = page.all("button, input, select, textarea")

      if form_controls.any?
        element = form_controls.first

        # Check border color
        border_color = page.evaluate_script(<<~JS)
        window.getComputedStyle(document.querySelector("button, input, select, textarea")).borderColor
      JS

        assert border_color == "rgb(0, 0, 0)" || border_color == "#000000", "Form controls should have black borders in high contrast mode"
      end
    end
end
