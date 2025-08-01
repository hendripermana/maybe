require "application_system_test_case"

class ModernizedPagesBugTrackerTest < ApplicationSystemTestCase
  setup do
    @user = users(:family_admin)
    sign_in @user
    @bugs_found = []
  end

  # Test for theme inconsistencies across all pages
  test "identify theme inconsistencies across all pages" do
    # Define pages to test
    pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]

    # Test light theme
    ensure_theme("light")

    pages.each do |page|
      visit page[:path]

      # Check for hardcoded dark colors in light theme
      check_for_hardcoded_colors("light", page[:name])

      # Check for inconsistent component styling
      check_component_styling_consistency(page[:name])
    end

    # Test dark theme
    ensure_theme("dark")

    pages.each do |page|
      visit page[:path]

      # Check for hardcoded light colors in dark theme
      check_for_hardcoded_colors("dark", page[:name])

      # Check for inconsistent component styling
      check_component_styling_consistency(page[:name])
    end

    # Report all bugs found
    report_bugs("Theme Inconsistencies")
  end

  # Test for layout issues across all pages
  test "identify layout issues across all pages" do
    # Define pages to test
    pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]

    # Define viewport sizes to test
    viewports = {
      desktop: [ 1920, 1080 ],
      tablet: [ 768, 1024 ],
      mobile: [ 375, 667 ]
    }

    viewports.each do |device, dimensions|
      with_viewport(*dimensions) do
        pages.each do |page|
          visit page[:path]

          # Check for overflow issues
          check_for_overflow_issues(page[:name], device)

          # Check for alignment issues
          check_for_alignment_issues(page[:name], device)

          # Check for spacing issues
          check_for_spacing_issues(page[:name], device)
        end
      end
    end

    # Report all bugs found
    report_bugs("Layout Issues")
  end

  # Test for component integration issues
  test "identify component integration issues" do
    # Define pages to test
    pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]

    pages.each do |page|
      visit page[:path]

      # Check for modal integration issues
      check_modal_integration(page[:name])

      # Check for form integration issues
      check_form_integration(page[:name])

      # Check for navigation integration issues
      check_navigation_integration(page[:name])

      # Check for chart integration issues
      check_chart_integration(page[:name])
    end

    # Report all bugs found
    report_bugs("Component Integration Issues")
  end

  # Test for accessibility issues
  test "identify accessibility issues" do
    # Define pages to test
    pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]

    pages.each do |page|
      visit page[:path]

      # Check for heading hierarchy issues
      check_heading_hierarchy(page[:name])

      # Check for form label issues
      check_form_labels(page[:name])

      # Check for color contrast issues
      check_color_contrast(page[:name])

      # Check for keyboard navigation issues
      check_keyboard_navigation(page[:name])
    end

    # Report all bugs found
    report_bugs("Accessibility Issues")
  end

  # Test for cross-browser issues
  test "identify cross-browser issues" do
    # Skip if not running in CI environment
    skip "Cross-browser tests only run in CI environment" unless ENV["CI"].present?

    # Define browsers to test
    browsers = [ :chrome, :firefox, :safari ]

    # Define pages to test
    pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]

    browsers.each do |browser|
      # Skip if browser is not available
      next unless browser_available?(browser)

      using_browser(browser) do
        pages.each do |page|
          visit page[:path]

          # Check for browser-specific rendering issues
          check_browser_rendering(page[:name], browser)

          # Check for browser-specific functionality issues
          check_browser_functionality(page[:name], browser)
        end
      end
    end

    # Report all bugs found
    report_bugs("Cross-Browser Issues")
  end

  # Test for performance issues
  test "identify performance issues" do
    # Define pages to test
    pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]

    pages.each do |page|
      # Measure page load time
      start_time = Time.current
      visit page[:path]
      end_time = Time.current

      load_time = (end_time - start_time).to_f
      if load_time > 2.0
        record_bug(
          page: page[:name],
          component: "Page Load",
          issue: "Slow page load time (#{load_time.round(2)}s)",
          severity: "Major"
        )
      end

      # Measure theme switching performance
      start_time = Time.current
      toggle_theme
      end_time = Time.current

      theme_switch_time = (end_time - start_time).to_f
      if theme_switch_time > 0.5
        record_bug(
          page: page[:name],
          component: "Theme Switching",
          issue: "Slow theme switching (#{theme_switch_time.round(2)}s)",
          severity: "Minor"
        )
      end

      # Check for layout shifts
      check_for_layout_shifts(page[:name])
    end

    # Report all bugs found
    report_bugs("Performance Issues")
  end

  private

    def check_for_hardcoded_colors(theme, page_name)
      # Check for hardcoded colors that don't respect the theme
      if theme == "light"
        # Check for hardcoded dark colors in light theme
        hardcoded_selectors = [
          ".bg-gray-900",
          ".bg-black",
          ".text-white",
          "[style*='background-color: #000']",
          "[style*='background-color: rgb(0, 0, 0)']",
          "[style*='color: #fff']",
          "[style*='color: rgb(255, 255, 255)']"
        ]
      else
        # Check for hardcoded light colors in dark theme
        hardcoded_selectors = [
          ".bg-white",
          ".bg-gray-100",
          ".text-black",
          "[style*='background-color: #fff']",
          "[style*='background-color: rgb(255, 255, 255)']",
          "[style*='color: #000']",
          "[style*='color: rgb(0, 0, 0)']"
        ]
      end

      hardcoded_selectors.each do |selector|
        if has_selector?(selector, visible: true)
          elements = all(selector, visible: true)
          elements.each do |element|
            record_bug(
              page: page_name,
              component: element.tag_name,
              issue: "Hardcoded #{theme == 'light' ? 'dark' : 'light'} color found: #{selector}",
              severity: "Major"
            )
          end
        end
      end
    end

    def check_component_styling_consistency(page_name)
      # Check buttons for consistent styling
      all("button", visible: true).each do |button|
        unless button[:class].include?("btn-modern")
          record_bug(
            page: page_name,
            component: "Button",
            issue: "Button missing modern styling class",
            severity: "Minor"
          )
        end
      end

      # Check cards for consistent styling
      all(".card", visible: true).each do |card|
        unless card[:class].include?("card-modern")
          record_bug(
            page: page_name,
            component: "Card",
            issue: "Card missing modern styling class",
            severity: "Minor"
          )
        end
      end

      # Check inputs for consistent styling
      all("input[type='text'], input[type='email'], input[type='password'], select", visible: true).each do |input|
        unless input[:class].include?("input-modern")
          record_bug(
            page: page_name,
            component: "Input",
            issue: "Input missing modern styling class",
            severity: "Minor"
          )
        end
      end
    end

    def check_for_overflow_issues(page_name, device)
      # Check for horizontal overflow
      page_width = page.evaluate_script("document.documentElement.clientWidth")
      body_width = page.evaluate_script("document.body.scrollWidth")

      if body_width > page_width
        record_bug(
          page: page_name,
          component: "Layout",
          issue: "Horizontal overflow detected on #{device} (#{body_width}px > #{page_width}px)",
          severity: "Major"
        )
      end

      # Check for element overflow
      all(".card, .container, section", visible: true).each do |element|
        element_width = page.evaluate_script("arguments[0].scrollWidth", element.native)
        container_width = page.evaluate_script("arguments[0].clientWidth", element.native)

        if element_width > container_width + 5 # Allow small rounding differences
          record_bug(
            page: page_name,
            component: "Element",
            issue: "Element overflow detected on #{device} (#{element_width}px > #{container_width}px)",
            severity: "Minor"
          )
        end
      end
    end

    def check_for_alignment_issues(page_name, device)
      # Check for misaligned elements
      container_elements = all(".container, section, .card", visible: true)

      container_elements.each do |container|
        # Get container left edge
        container_left = page.evaluate_script("arguments[0].getBoundingClientRect().left", container.native)

        # Check child elements for alignment
        child_elements = container.all("div, p, h1, h2, h3, h4, h5, h6", visible: true)

        child_elements.each do |child|
          child_left = page.evaluate_script("arguments[0].getBoundingClientRect().left", child.native)

          # Check if child is significantly misaligned (more than 2px difference)
          if (child_left - container_left).abs > 2 && (child_left - container_left).abs < 20
            # Ignore intentional indentation (>= 20px)
            record_bug(
              page: page_name,
              component: "Alignment",
              issue: "Misaligned element detected on #{device} (#{(child_left - container_left).round(2)}px offset)",
              severity: "Minor"
            )
          end
        end
      end
    end

    def check_for_spacing_issues(page_name, device)
      # Check for inconsistent spacing between elements
      container_elements = all(".container, section, .card", visible: true)

      container_elements.each do |container|
        # Check spacing between adjacent elements
        child_elements = container.all("div, p, h1, h2, h3, h4, h5, h6", visible: true)

        child_elements.each_cons(2) do |el1, el2|
          el1_bottom = page.evaluate_script("arguments[0].getBoundingClientRect().bottom", el1.native)
          el2_top = page.evaluate_script("arguments[0].getBoundingClientRect().top", el2.native)

          spacing = el2_top - el1_bottom

          # Check for very small or negative spacing
          if spacing < 2 && spacing > -10 # Ignore overlapping elements that are likely intentional
            record_bug(
              page: page_name,
              component: "Spacing",
              issue: "Insufficient spacing between elements on #{device} (#{spacing.round(2)}px)",
              severity: "Minor"
            )
          end
        end
      end
    end

    def check_modal_integration(page_name)
      # Check for modal triggers
      if has_selector?("[data-modal-trigger]")
        find("[data-modal-trigger]", match: :first).click

        # Verify modal opens
        unless has_selector?(".modal-dialog")
          record_bug(
            page: page_name,
            component: "Modal",
            issue: "Modal does not open when trigger is clicked",
            severity: "Major"
          )
        else
          # Check modal styling
          modal = find(".modal-dialog")

          # Check for theme consistency
          theme = current_theme
          modal_background = page.evaluate_script("window.getComputedStyle(arguments[0]).backgroundColor", modal.native)

          if (theme == "light" && modal_background.include?("rgb(0, 0, 0)")) ||
             (theme == "dark" && modal_background.include?("rgb(255, 255, 255)"))
            record_bug(
              page: page_name,
              component: "Modal",
              issue: "Modal background color does not match current theme",
              severity: "Major"
            )
          end

          # Check modal close functionality
          find(".modal-close").click

          unless has_no_selector?(".modal-dialog")
            record_bug(
              page: page_name,
              component: "Modal",
              issue: "Modal does not close when close button is clicked",
              severity: "Major"
            )
          end
        end
      end
    end

    def check_form_integration(page_name)
      # Check for forms
      if has_selector?("form")
        form = find("form", match: :first)

        # Check for form elements
        form_elements = form.all("input, select, textarea", visible: true)

        if form_elements.empty?
          record_bug(
            page: page_name,
            component: "Form",
            issue: "Form has no input elements",
            severity: "Minor"
          )
        else
          # Check for submit button
          unless form.has_selector?("button[type='submit'], input[type='submit']")
            record_bug(
              page: page_name,
              component: "Form",
              issue: "Form has no submit button",
              severity: "Major"
            )
          end

          # Check for consistent styling
          form_elements.each do |element|
            unless element[:class].include?("input-modern")
              record_bug(
                page: page_name,
                component: "Form",
                issue: "Form element missing modern styling class",
                severity: "Minor"
              )
            end
          end
        end
      end
    end

    def check_navigation_integration(page_name)
      # Check for navigation elements
      if has_selector?("nav")
        nav = find("nav", match: :first)

        # Check for navigation links
        nav_links = nav.all("a", visible: true)

        if nav_links.empty?
          record_bug(
            page: page_name,
            component: "Navigation",
            issue: "Navigation has no links",
            severity: "Major"
          )
        else
          # Check for active state
          unless nav.has_selector?("a[aria-current='page'], a.active")
            record_bug(
              page: page_name,
              component: "Navigation",
              issue: "Navigation has no active state indicator",
              severity: "Minor"
            )
          end

          # Check for consistent styling
          nav_links.each do |link|
            unless link[:class].include?("nav-modern") || link.find(:xpath, "..")[:"class"].include?("nav-modern")
              record_bug(
                page: page_name,
                component: "Navigation",
                issue: "Navigation link missing modern styling class",
                severity: "Minor"
              )
            end
          end
        end
      end
    end

    def check_chart_integration(page_name)
      # Check for charts
      if has_selector?(".chart, [data-chart]")
        chart = find(".chart, [data-chart]", match: :first)

        # Check for chart content
        unless chart.has_selector?("svg, canvas")
          record_bug(
            page: page_name,
            component: "Chart",
            issue: "Chart has no SVG or canvas element",
            severity: "Major"
          )
        end

        # Check for theme consistency
        theme = current_theme
        chart_background = page.evaluate_script("window.getComputedStyle(arguments[0]).backgroundColor", chart.native)

        if (theme == "light" && chart_background.include?("rgb(0, 0, 0)")) ||
           (theme == "dark" && chart_background.include?("rgb(255, 255, 255)"))
          record_bug(
            page: page_name,
            component: "Chart",
            issue: "Chart background color does not match current theme",
            severity: "Major"
          )
        end
      end
    end

    def check_heading_hierarchy(page_name)
      # Get all headings
      headings = all("h1, h2, h3, h4, h5, h6", visible: true)

      # Check for proper heading hierarchy
      heading_levels = headings.map { |h| h.tag_name[1].to_i }

      heading_levels.each_cons(2) do |level1, level2|
        if level2 > level1 + 1
          record_bug(
            page: page_name,
            component: "Headings",
            issue: "Heading hierarchy skips from h#{level1} to h#{level2}",
            severity: "Minor"
          )
        end
      end

      # Check for multiple h1 elements
      h1_count = headings.count { |h| h.tag_name == "h1" }

      if h1_count > 1
        record_bug(
          page: page_name,
          component: "Headings",
          issue: "Multiple h1 elements found (#{h1_count})",
          severity: "Minor"
        )
      end
    end

    def check_form_labels(page_name)
      # Check for form controls with labels
      all("input, select, textarea", visible: true).each do |control|
        next if control[:type] == "hidden" || control[:type] == "submit" || control[:type] == "button"

        has_label = false

        # Check for label with for attribute
        if control[:id].present?
          has_label = has_selector?("label[for='#{control[:id]}']")
        end

        # Check for wrapping label
        unless has_label
          has_label = control.find(:xpath, "ancestor::label").present? rescue false
        end

        # Check for aria-label
        unless has_label
          has_label = control[:aria_label].present?
        end

        # Check for aria-labelledby
        unless has_label
          has_label = control[:aria_labelledby].present? &&
                      has_selector?("##{control[:aria_labelledby]}")
        end

        unless has_label
          record_bug(
            page: page_name,
            component: "Form",
            issue: "Form control missing label or accessible name",
            severity: "Major"
          )
        end
      end
    end

    def check_color_contrast(page_name)
      # Check text elements for color contrast
      text_elements = all("p, h1, h2, h3, h4, h5, h6, label, button, a", visible: true)

      text_elements.each do |element|
        # Get text and background colors
        color = page.evaluate_script("window.getComputedStyle(arguments[0]).color", element.native)
        background = page.evaluate_script("window.getComputedStyle(arguments[0]).backgroundColor", element.native)

        # Skip if background is transparent
        next if background == "rgba(0, 0, 0, 0)" || background == "transparent"

        # Simple check that colors are different (a more sophisticated test would calculate contrast ratio)
        if color == background
          record_bug(
            page: page_name,
            component: "Color Contrast",
            issue: "Text and background colors are the same",
            severity: "Major"
          )
        end
      end
    end

    def check_keyboard_navigation(page_name)
      # Tab to focus on first interactive element
      find("body").send_keys(:tab)

      # Check if focus is visible
      unless has_selector?(":focus")
        record_bug(
          page: page_name,
          component: "Keyboard Navigation",
          issue: "Focus not visible after tabbing",
          severity: "Major"
        )
      else
        # Get focused element
        focused_element = find(:focus)

        # Check for visible focus indicator
        styles = page.evaluate_script("window.getComputedStyle(arguments[0])", focused_element.native)

        has_outline = styles["outline"] != "none" && styles["outline-width"] != "0px"
        has_box_shadow = styles["boxShadow"] != "none"
        has_border = styles["border"] != "none" && styles["borderWidth"] != "0px"

        unless has_outline || has_box_shadow || has_border
          record_bug(
            page: page_name,
            component: "Keyboard Navigation",
            issue: "Focus indicator not visible",
            severity: "Major"
          )
        end
      end
    end

    def check_browser_rendering(page_name, browser)
      # Check for browser-specific rendering issues

      # Check for visible elements
      unless has_selector?("body *", visible: true)
        record_bug(
          page: page_name,
          component: "Browser Rendering",
          issue: "No visible elements in #{browser}",
          severity: "Critical"
        )
      end

      # Check for layout issues
      if has_selector?(".container, main")
        container = find(".container, main", match: :first)

        # Check container width
        container_width = page.evaluate_script("arguments[0].clientWidth", container.native)
        window_width = page.evaluate_script("window.innerWidth")

        if container_width > window_width
          record_bug(
            page: page_name,
            component: "Browser Rendering",
            issue: "Container wider than viewport in #{browser}",
            severity: "Major"
          )
        end
      end
    end

    def check_browser_functionality(page_name, browser)
      # Check for browser-specific functionality issues

      # Check theme switching
      if has_selector?("[data-theme-toggle]")
        original_theme = current_theme

        find("[data-theme-toggle]").click

        new_theme = current_theme

        unless new_theme != original_theme
          record_bug(
            page: page_name,
            component: "Browser Functionality",
            issue: "Theme switching does not work in #{browser}",
            severity: "Major"
          )
        end
      end

      # Check modal functionality
      if has_selector?("[data-modal-trigger]")
        find("[data-modal-trigger]", match: :first).click

        unless has_selector?(".modal-dialog")
          record_bug(
            page: page_name,
            component: "Browser Functionality",
            issue: "Modal does not open in #{browser}",
            severity: "Major"
          )
        else
          find(".modal-close").click

          unless has_no_selector?(".modal-dialog")
            record_bug(
              page: page_name,
              component: "Browser Functionality",
              issue: "Modal does not close in #{browser}",
              severity: "Major"
            )
          end
        end
      end
    end

    def check_for_layout_shifts(page_name)
      # Capture initial positions of key elements
      initial_positions = {}

      all(".card, .container, main > *", visible: true).each_with_index do |element, index|
        rect = page.evaluate_script("arguments[0].getBoundingClientRect()", element.native)
        initial_positions["element-#{index}"] = { top: rect["top"], left: rect["left"] }
      end

      # Trigger potential layout shifts (e.g., by loading images or expanding elements)
      page.execute_script("window.dispatchEvent(new Event('resize'))")
      sleep 0.5

      # Check if elements moved
      all(".card, .container, main > *", visible: true).each_with_index do |element, index|
        next unless initial_positions["element-#{index}"]

        rect = page.evaluate_script("arguments[0].getBoundingClientRect()", element.native)

        # Allow small tolerance for rounding errors (2 pixels)
        if (rect["top"] - initial_positions["element-#{index}"][:top]).abs > 2
          record_bug(
            page: page_name,
            component: "Layout Stability",
            issue: "Element shifted vertically by #{(rect['top'] - initial_positions['element-#{index}'][:top]).round(2)}px",
            severity: "Minor"
          )
        end

        if (rect["left"] - initial_positions["element-#{index}"][:left]).abs > 2
          record_bug(
            page: page_name,
            component: "Layout Stability",
            issue: "Element shifted horizontally by #{(rect['left'] - initial_positions['element-#{index}'][:left]).round(2)}px",
            severity: "Minor"
          )
        end
      end
    end

    def record_bug(page:, component:, issue:, severity:)
      @bugs_found << {
        page: page,
        component: component,
        issue: issue,
        severity: severity
      }
    end

    def report_bugs(category)
      puts "\n=== #{category} ==="

      if @bugs_found.empty?
        puts "No issues found."
      else
        # Group bugs by page
        bugs_by_page = @bugs_found.group_by { |bug| bug[:page] }

        bugs_by_page.each do |page, bugs|
          puts "\nPage: #{page}"

          # Group bugs by severity
          bugs_by_severity = bugs.group_by { |bug| bug[:severity] }

          # Report critical bugs first
          [ "Critical", "Major", "Minor" ].each do |severity|
            next unless bugs_by_severity[severity]

            puts "  #{severity} Issues:"

            bugs_by_severity[severity].each do |bug|
              puts "    - [#{bug[:component]}] #{bug[:issue]}"
            end
          end
        end
      end

      # Clear bugs for next test
      @bugs_found = []
    end

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
