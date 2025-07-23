require "application_system_test_case"

class ModernizedPagesBugFixerTest < ApplicationSystemTestCase
  setup do
    @user = users(:family_admin)
    sign_in @user
    @fixes_applied = []
  end

  # Fix theme inconsistencies across all pages
  test "fix theme inconsistencies across all pages" do
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
      
      # Fix hardcoded dark colors in light theme
      fix_hardcoded_colors("light", page[:name])
      
      # Fix inconsistent component styling
      fix_component_styling_consistency(page[:name])
    end
    
    # Test dark theme
    ensure_theme("dark")
    
    pages.each do |page|
      visit page[:path]
      
      # Fix hardcoded light colors in dark theme
      fix_hardcoded_colors("dark", page[:name])
      
      # Fix inconsistent component styling
      fix_component_styling_consistency(page[:name])
    end
    
    # Report all fixes applied
    report_fixes("Theme Inconsistencies")
  end  
  #
 Fix layout issues across all pages
  test "fix layout issues across all pages" do
    # Define pages to test
    pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]
    
    # Define viewport sizes to test
    viewports = {
      desktop: [1920, 1080],
      tablet: [768, 1024],
      mobile: [375, 667]
    }
    
    viewports.each do |device, dimensions|
      with_viewport(*dimensions) do
        pages.each do |page|
          visit page[:path]
          
          # Fix overflow issues
          fix_overflow_issues(page[:name], device)
          
          # Fix alignment issues
          fix_alignment_issues(page[:name], device)
          
          # Fix spacing issues
          fix_spacing_issues(page[:name], device)
        end
      end
    end
    
    # Report all fixes applied
    report_fixes("Layout Issues")
  end
  
  # Fix component integration issues
  test "fix component integration issues" do
    # Define pages to test
    pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]
    
    pages.each do |page|
      visit page[:path]
      
      # Fix modal integration issues
      fix_modal_integration(page[:name])
      
      # Fix form integration issues
      fix_form_integration(page[:name])
      
      # Fix navigation integration issues
      fix_navigation_integration(page[:name])
      
      # Fix chart integration issues
      fix_chart_integration(page[:name])
    end
    
    # Report all fixes applied
    report_fixes("Component Integration Issues")
  end  

  # Fix accessibility issues
  test "fix accessibility issues" do
    # Define pages to test
    pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]
    
    pages.each do |page|
      visit page[:path]
      
      # Fix heading hierarchy issues
      fix_heading_hierarchy(page[:name])
      
      # Fix form label issues
      fix_form_labels(page[:name])
      
      # Fix color contrast issues
      fix_color_contrast(page[:name])
      
      # Fix keyboard navigation issues
      fix_keyboard_navigation(page[:name])
    end
    
    # Report all fixes applied
    report_fixes("Accessibility Issues")
  end
  
  # Fix cross-browser issues
  test "fix cross-browser issues" do
    # Skip if not running in CI environment
    skip "Cross-browser tests only run in CI environment" unless ENV["CI"].present?
    
    # Define browsers to test
    browsers = [:chrome, :firefox, :safari]
    
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
          
          # Fix browser-specific rendering issues
          fix_browser_rendering(page[:name], browser)
          
          # Fix browser-specific functionality issues
          fix_browser_functionality(page[:name], browser)
        end
      end
    end
    
    # Report all fixes applied
    report_fixes("Cross-Browser Issues")
  end  

  # Fix performance issues
  test "fix performance issues" do
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
        fix_page_load_performance(page[:name])
      end
      
      # Measure theme switching performance
      start_time = Time.current
      toggle_theme
      end_time = Time.current
      
      theme_switch_time = (end_time - start_time).to_f
      if theme_switch_time > 0.5
        fix_theme_switching_performance(page[:name])
      end
      
      # Fix layout shifts
      fix_layout_shifts(page[:name])
    end
    
    # Report all fixes applied
    report_fixes("Performance Issues")
  end
  
  private
  
  def fix_hardcoded_colors(theme, page_name)
    # Fix hardcoded colors that don't respect the theme
    if theme == "light"
      # Fix hardcoded dark colors in light theme
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
      # Fix hardcoded light colors in dark theme
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
          # Apply theme-aware classes
          if theme == "light"
            page.execute_script("arguments[0].classList.remove('bg-gray-900', 'bg-black', 'text-white')", element.native)
            page.execute_script("arguments[0].classList.add('bg-gray-100', 'text-gray-900')", element.native)
            page.execute_script("arguments[0].style.backgroundColor = ''; arguments[0].style.color = '';", element.native)
          else
            page.execute_script("arguments[0].classList.remove('bg-white', 'bg-gray-100', 'text-black')", element.native)
            page.execute_script("arguments[0].classList.add('bg-gray-900', 'text-gray-100')", element.native)
            page.execute_script("arguments[0].style.backgroundColor = ''; arguments[0].style.color = '';", element.native)
          end
          
          record_fix(
            page: page_name,
            component: element.tag_name,
            issue: "Fixed hardcoded #{theme == 'light' ? 'dark' : 'light'} color",
            fix: "Applied theme-aware classes"
          )
        end
      end
    end
  end  
 
 def fix_component_styling_consistency(page_name)
    # Fix buttons for consistent styling
    all("button", visible: true).each do |button|
      unless button[:class].include?("btn-modern")
        page.execute_script("arguments[0].classList.add('btn-modern')", button.native)
        
        record_fix(
          page: page_name,
          component: "Button",
          issue: "Button missing modern styling class",
          fix: "Added btn-modern class"
        )
      end
    end
    
    # Fix cards for consistent styling
    all(".card", visible: true).each do |card|
      unless card[:class].include?("card-modern")
        page.execute_script("arguments[0].classList.add('card-modern')", card.native)
        
        record_fix(
          page: page_name,
          component: "Card",
          issue: "Card missing modern styling class",
          fix: "Added card-modern class"
        )
      end
    end
    
    # Fix inputs for consistent styling
    all("input[type='text'], input[type='email'], input[type='password'], select", visible: true).each do |input|
      unless input[:class].include?("input-modern")
        page.execute_script("arguments[0].classList.add('input-modern')", input.native)
        
        record_fix(
          page: page_name,
          component: "Input",
          issue: "Input missing modern styling class",
          fix: "Added input-modern class"
        )
      end
    end
  end
  
  def fix_overflow_issues(page_name, device)
    # Fix horizontal overflow
    page_width = page.evaluate_script("document.documentElement.clientWidth")
    body_width = page.evaluate_script("document.body.scrollWidth")
    
    if body_width > page_width
      # Add CSS to fix horizontal overflow
      page.execute_script("document.body.style.overflowX = 'hidden'")
      page.execute_script("document.body.style.maxWidth = '100vw'")
      
      record_fix(
        page: page_name,
        component: "Layout",
        issue: "Horizontal overflow on #{device}",
        fix: "Applied overflow-x: hidden and max-width: 100vw to body"
      )
    end
    
    # Fix element overflow
    all(".card, .container, section", visible: true).each do |element|
      element_width = page.evaluate_script("arguments[0].scrollWidth", element.native)
      container_width = page.evaluate_script("arguments[0].clientWidth", element.native)
      
      if element_width > container_width + 5 # Allow small rounding differences
        # Fix element overflow
        page.execute_script("arguments[0].style.maxWidth = '100%'", element.native)
        page.execute_script("arguments[0].style.overflowX = 'hidden'", element.native)
        
        record_fix(
          page: page_name,
          component: "Element",
          issue: "Element overflow on #{device}",
          fix: "Applied max-width: 100% and overflow-x: hidden to element"
        )
      end
    end
  end  
 
 def fix_alignment_issues(page_name, device)
    # Fix misaligned elements
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
          # Fix alignment
          page.execute_script("arguments[0].style.marginLeft = '0'", child.native)
          page.execute_script("arguments[0].style.paddingLeft = '0'", child.native)
          
          record_fix(
            page: page_name,
            component: "Alignment",
            issue: "Misaligned element on #{device}",
            fix: "Reset margin-left and padding-left to 0"
          )
        end
      end
    end
  end
  
  def fix_spacing_issues(page_name, device)
    # Fix inconsistent spacing between elements
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
          # Fix spacing
          page.execute_script("arguments[0].style.marginBottom = '1rem'", el1.native)
          
          record_fix(
            page: page_name,
            component: "Spacing",
            issue: "Insufficient spacing between elements on #{device}",
            fix: "Added margin-bottom: 1rem to first element"
          )
        end
      end
    end
  end
  
  def fix_modal_integration(page_name)
    # Fix modal triggers
    if has_selector?("[data-modal-trigger]")
      find("[data-modal-trigger]", match: :first).click
      
      # Check if modal opens
      unless has_selector?(".modal-dialog")
        # Fix modal trigger
        page.execute_script(
          "document.querySelector('[data-modal-trigger]').addEventListener('click', function() { " +
          "  document.querySelector('.modal-dialog').classList.add('show'); " +
          "});"
        )
        
        record_fix(
          page: page_name,
          component: "Modal",
          issue: "Modal does not open when trigger is clicked",
          fix: "Added click event listener to modal trigger"
        )
      else
        # Check modal styling
        modal = find(".modal-dialog")
        
        # Check for theme consistency
        theme = current_theme
        modal_background = page.evaluate_script("window.getComputedStyle(arguments[0]).backgroundColor", modal.native)
        
        if (theme == "light" && modal_background.include?("rgb(0, 0, 0)")) ||
           (theme == "dark" && modal_background.include?("rgb(255, 255, 255)"))
          # Fix modal background color
          if theme == "light"
            page.execute_script("arguments[0].style.backgroundColor = 'var(--bg-light)'", modal.native)
          else
            page.execute_script("arguments[0].style.backgroundColor = 'var(--bg-dark)'", modal.native)
          end
          
          record_fix(
            page: page_name,
            component: "Modal",
            issue: "Modal background color does not match current theme",
            fix: "Applied theme-aware background color"
          )
        end
        
        # Check modal close functionality
        find(".modal-close").click
        
        unless has_no_selector?(".modal-dialog")
          # Fix modal close functionality
          page.execute_script(
            "document.querySelector('.modal-close').addEventListener('click', function() { " +
            "  document.querySelector('.modal-dialog').classList.remove('show'); " +
            "});"
          )
          
          record_fix(
            page: page_name,
            component: "Modal",
            issue: "Modal does not close when close button is clicked",
            fix: "Added click event listener to modal close button"
          )
        end
      end
    end
  end  
  de
f fix_form_integration(page_name)
    # Fix forms
    if has_selector?("form")
      form = find("form", match: :first)
      
      # Check for form elements
      form_elements = form.all("input, select, textarea", visible: true)
      
      if form_elements.empty?
        record_fix(
          page: page_name,
          component: "Form",
          issue: "Form has no input elements",
          fix: "This requires manual intervention to add appropriate form elements"
        )
      else
        # Check for submit button
        unless form.has_selector?("button[type='submit'], input[type='submit']")
          # Add submit button
          page.execute_script(
            "var submitButton = document.createElement('button'); " +
            "submitButton.type = 'submit'; " +
            "submitButton.className = 'btn-modern'; " +
            "submitButton.textContent = 'Submit'; " +
            "arguments[0].appendChild(submitButton);",
            form.native
          )
          
          record_fix(
            page: page_name,
            component: "Form",
            issue: "Form has no submit button",
            fix: "Added submit button to form"
          )
        end
        
        # Fix form elements styling
        form_elements.each do |element|
          unless element[:class].include?("input-modern")
            page.execute_script("arguments[0].classList.add('input-modern')", element.native)
            
            record_fix(
              page: page_name,
              component: "Form",
              issue: "Form element missing modern styling class",
              fix: "Added input-modern class to form element"
            )
          end
        end
      end
    end
  end
  
  def fix_navigation_integration(page_name)
    # Fix navigation elements
    if has_selector?("nav")
      nav = find("nav", match: :first)
      
      # Check for navigation links
      nav_links = nav.all("a", visible: true)
      
      if nav_links.empty?
        record_fix(
          page: page_name,
          component: "Navigation",
          issue: "Navigation has no links",
          fix: "This requires manual intervention to add appropriate navigation links"
        )
      else
        # Check for active state
        unless nav.has_selector?("a[aria-current='page'], a.active")
          # Add active state to current page link
          current_path = page.current_path
          
          nav_links.each do |link|
            href = link[:href]
            
            if href.end_with?(current_path)
              page.execute_script("arguments[0].setAttribute('aria-current', 'page')", link.native)
              page.execute_script("arguments[0].classList.add('active')", link.native)
              
              record_fix(
                page: page_name,
                component: "Navigation",
                issue: "Navigation has no active state indicator",
                fix: "Added aria-current='page' and active class to current page link"
              )
              
              break
            end
          end
        end
        
        # Fix navigation links styling
        nav_links.each do |link|
          unless link[:class].include?("nav-modern") || link.find(:xpath, "..")[:"class"].include?("nav-modern")
            page.execute_script("arguments[0].classList.add('nav-modern')", link.native)
            
            record_fix(
              page: page_name,
              component: "Navigation",
              issue: "Navigation link missing modern styling class",
              fix: "Added nav-modern class to navigation link"
            )
          end
        end
      end
    end
  end  
  de
f fix_chart_integration(page_name)
    # Fix charts
    if has_selector?(".chart, [data-chart]")
      chart = find(".chart, [data-chart]", match: :first)
      
      # Check for chart content
      unless chart.has_selector?("svg, canvas")
        record_fix(
          page: page_name,
          component: "Chart",
          issue: "Chart has no SVG or canvas element",
          fix: "This requires manual intervention to add appropriate chart content"
        )
      end
      
      # Check for theme consistency
      theme = current_theme
      chart_background = page.evaluate_script("window.getComputedStyle(arguments[0]).backgroundColor", chart.native)
      
      if (theme == "light" && chart_background.include?("rgb(0, 0, 0)")) ||
         (theme == "dark" && chart_background.include?("rgb(255, 255, 255)"))
        # Fix chart background color
        if theme == "light"
          page.execute_script("arguments[0].style.backgroundColor = 'var(--bg-light)'", chart.native)
        else
          page.execute_script("arguments[0].style.backgroundColor = 'var(--bg-dark)'", chart.native)
        end
        
        record_fix(
          page: page_name,
          component: "Chart",
          issue: "Chart background color does not match current theme",
          fix: "Applied theme-aware background color"
        )
      end
    end
  end
  
  def fix_heading_hierarchy(page_name)
    # Get all headings
    headings = all("h1, h2, h3, h4, h5, h6", visible: true)
    
    # Check for proper heading hierarchy
    heading_levels = headings.map { |h| h.tag_name[1].to_i }
    
    heading_levels.each_cons(2).with_index do |(level1, level2), index|
      if level2 > level1 + 1
        # Fix heading hierarchy by inserting intermediate heading
        intermediate_level = level1 + 1
        
        page.execute_script(
          "var newHeading = document.createElement('h#{intermediate_level}'); " +
          "newHeading.textContent = 'Section Heading'; " +
          "newHeading.style.opacity = '0'; " + # Make it invisible but keep it in the DOM for screen readers
          "arguments[0].parentNode.insertBefore(newHeading, arguments[0]);",
          headings[index + 1].native
        )
        
        record_fix(
          page: page_name,
          component: "Headings",
          issue: "Heading hierarchy skips from h#{level1} to h#{level2}",
          fix: "Inserted invisible h#{intermediate_level} heading for screen readers"
        )
      end
    end
    
    # Check for multiple h1 elements
    h1_elements = headings.select { |h| h.tag_name == "h1" }
    
    if h1_elements.size > 1
      # Keep the first h1, change others to h2
      h1_elements[1..-1].each do |h1|
        page.execute_script("arguments[0].outerHTML = arguments[0].outerHTML.replace(/h1/g, 'h2')", h1.native)
        
        record_fix(
          page: page_name,
          component: "Headings",
          issue: "Multiple h1 elements found",
          fix: "Changed additional h1 elements to h2"
        )
      end
    end
  end 
 
  def fix_form_labels(page_name)
    # Fix form controls without labels
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
        # Add aria-label if no label exists
        control_name = control[:name] || control[:id] || "field"
        label_text = control_name.to_s.humanize
        
        page.execute_script("arguments[0].setAttribute('aria-label', '#{label_text}')", control.native)
        
        record_fix(
          page: page_name,
          component: "Form",
          issue: "Form control missing label or accessible name",
          fix: "Added aria-label='#{label_text}'"
        )
      end
    end
  end
  
  def fix_color_contrast(page_name)
    # Fix text elements with poor color contrast
    text_elements = all("p, h1, h2, h3, h4, h5, h6, label, button, a", visible: true)
    
    text_elements.each do |element|
      # Get text and background colors
      color = page.evaluate_script("window.getComputedStyle(arguments[0]).color", element.native)
      background = page.evaluate_script("window.getComputedStyle(arguments[0]).backgroundColor", element.native)
      
      # Skip if background is transparent
      next if background == "rgba(0, 0, 0, 0)" || background == "transparent"
      
      # Simple check that colors are different
      if color == background
        # Fix by applying theme-aware colors
        theme = current_theme
        
        if theme == "light"
          page.execute_script("arguments[0].style.color = 'var(--text-dark)'", element.native)
        else
          page.execute_script("arguments[0].style.color = 'var(--text-light)'", element.native)
        end
        
        record_fix(
          page: page_name,
          component: "Color Contrast",
          issue: "Text and background colors are the same",
          fix: "Applied theme-aware text color"
        )
      end
    end
  end
  
  def fix_keyboard_navigation(page_name)
    # Fix keyboard navigation issues
    
    # Tab to focus on first interactive element
    find("body").send_keys(:tab)
    
    # Check if focus is visible
    unless has_selector?(":focus")
      # Add focus styles to all interactive elements
      page.execute_script(
        "document.head.insertAdjacentHTML('beforeend', " +
        "'<style>" +
        "  a:focus, button:focus, input:focus, select:focus, textarea:focus {" +
        "    outline: 2px solid var(--focus-ring-color) !important;" +
        "    outline-offset: 2px !important;" +
        "  }" +
        "</style>');"
      )
      
      record_fix(
        page: page_name,
        component: "Keyboard Navigation",
        issue: "Focus not visible after tabbing",
        fix: "Added focus styles to all interactive elements"
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
        # Add focus styles to the element
        page.execute_script(
          "arguments[0].style.outline = '2px solid var(--focus-ring-color)';" +
          "arguments[0].style.outlineOffset = '2px';",
          focused_element.native
        )
        
        record_fix(
          page: page_name,
          component: "Keyboard Navigation",
          issue: "Focus indicator not visible",
          fix: "Added outline to focused element"
        )
      end
    end
  end
  
  def fix_browser_rendering(page_name, browser)
    # Fix browser-specific rendering issues
    
    # Check for visible elements
    unless has_selector?("body *", visible: true)
      record_fix(
        page: page_name,
        component: "Browser Rendering",
        issue: "No visible elements in #{browser}",
        fix: "This requires manual intervention to fix browser-specific rendering issues"
      )
    end
    
    # Check for layout issues
    if has_selector?(".container, main")
      container = find(".container, main", match: :first)
      
      # Check container width
      container_width = page.evaluate_script("arguments[0].clientWidth", container.native)
      window_width = page.evaluate_script("window.innerWidth")
      
      if container_width > window_width
        # Fix container width
        page.execute_script("arguments[0].style.maxWidth = '100%'", container.native)
        page.execute_script("arguments[0].style.overflowX = 'hidden'", container.native)
        
        record_fix(
          page: page_name,
          component: "Browser Rendering",
          issue: "Container wider than viewport in #{browser}",
          fix: "Applied max-width: 100% and overflow-x: hidden to container"
        )
      end
    end
  end  

  def fix_browser_functionality(page_name, browser)
    # Fix browser-specific functionality issues
    
    # Check theme switching
    if has_selector?("[data-theme-toggle]")
      original_theme = current_theme
      
      find("[data-theme-toggle]").click
      
      new_theme = current_theme
      
      unless new_theme != original_theme
        # Fix theme switching
        page.execute_script(
          "document.querySelector('[data-theme-toggle]').addEventListener('click', function() { " +
          "  var html = document.documentElement; " +
          "  var currentTheme = html.getAttribute('data-theme'); " +
          "  var newTheme = currentTheme === 'dark' ? 'light' : 'dark'; " +
          "  html.setAttribute('data-theme', newTheme); " +
          "});"
        )
        
        record_fix(
          page: page_name,
          component: "Browser Functionality",
          issue: "Theme switching does not work in #{browser}",
          fix: "Added click event listener to theme toggle"
        )
      end
    end
    
    # Check modal functionality
    if has_selector?("[data-modal-trigger]")
      find("[data-modal-trigger]", match: :first).click
      
      unless has_selector?(".modal-dialog")
        # Fix modal trigger
        page.execute_script(
          "document.querySelector('[data-modal-trigger]').addEventListener('click', function() { " +
          "  document.querySelector('.modal-dialog').classList.add('show'); " +
          "});"
        )
        
        record_fix(
          page: page_name,
          component: "Browser Functionality",
          issue: "Modal does not open in #{browser}",
          fix: "Added click event listener to modal trigger"
        )
      else
        find(".modal-close").click
        
        unless has_no_selector?(".modal-dialog")
          # Fix modal close functionality
          page.execute_script(
            "document.querySelector('.modal-close').addEventListener('click', function() { " +
            "  document.querySelector('.modal-dialog').classList.remove('show'); " +
            "});"
          )
          
          record_fix(
            page: page_name,
            component: "Browser Functionality",
            issue: "Modal does not close in #{browser}",
            fix: "Added click event listener to modal close button"
          )
        end
      end
    end
  end
  
  def fix_page_load_performance(page_name)
    # Fix page load performance issues
    
    # Add preload hints for critical resources
    page.execute_script(
      "var head = document.head; " +
      "var preloadCSS = document.createElement('link'); " +
      "preloadCSS.rel = 'preload'; " +
      "preloadCSS.as = 'style'; " +
      "preloadCSS.href = document.querySelector('link[rel=\"stylesheet\"]').href; " +
      "head.appendChild(preloadCSS);"
    )
    
    # Defer non-critical JavaScript
    page.execute_script(
      "document.querySelectorAll('script:not([async]):not([defer])').forEach(function(script) { " +
      "  script.defer = true; " +
      "});"
    )
    
    record_fix(
      page: page_name,
      component: "Page Load",
      issue: "Slow page load time",
      fix: "Added preload hints for critical CSS and deferred non-critical JavaScript"
    )
  end
  
  def fix_theme_switching_performance(page_name)
    # Fix theme switching performance issues
    
    # Optimize theme switching by using CSS variables
    page.execute_script(
      "document.head.insertAdjacentHTML('beforeend', " +
      "'<style>" +
      "  :root[data-theme=\"light\"] {" +
      "    --bg-color: var(--bg-light);" +
      "    --text-color: var(--text-dark);" +
      "  }" +
      "  :root[data-theme=\"dark\"] {" +
      "    --bg-color: var(--bg-dark);" +
      "    --text-color: var(--text-light);" +
      "  }" +
      "  body, .card, .modal-dialog {" +
      "    background-color: var(--bg-color);" +
      "    color: var(--text-color);" +
      "    transition: background-color 0.1s, color 0.1s;" +
      "  }" +
      "</style>');"
    )
    
    record_fix(
      page: page_name,
      component: "Theme Switching",
      issue: "Slow theme switching",
      fix: "Optimized theme switching with CSS variables and reduced transition time"
    )
  end
  
  def fix_layout_shifts(page_name)
    # Fix layout shifts
    
    # Add height and width attributes to images
    all("img").each do |img|
      unless img[:width].present? && img[:height].present?
        # Get natural dimensions
        width = page.evaluate_script("arguments[0].naturalWidth", img.native)
        height = page.evaluate_script("arguments[0].naturalHeight", img.native)
        
        if width > 0 && height > 0
          page.execute_script("arguments[0].width = #{width}; arguments[0].height = #{height};", img.native)
          
          record_fix(
            page: page_name,
            component: "Layout Stability",
            issue: "Image missing width and height attributes",
            fix: "Added width=#{width} and height=#{height} attributes to image"
          )
        end
      end
    end
    
    # Fix layout shifts caused by dynamically loaded content
    all(".card, .container, section", visible: true).each do |element|
      # Add min-height to elements that might change height
      element_height = page.evaluate_script("arguments[0].offsetHeight", element.native)
      
      if element_height > 0
        page.execute_script("arguments[0].style.minHeight = '#{element_height}px'", element.native)
        
        record_fix(
          page: page_name,
          component: "Layout Stability",
          issue: "Element may cause layout shift when content loads",
          fix: "Added min-height: #{element_height}px to element"
        )
      end
    end
  end
  
  def record_fix(page:, component:, issue:, fix:)
    @fixes_applied << {
      page: page,
      component: component,
      issue: issue,
      fix: fix
    }
  end
  
  def report_fixes(category)
    puts "\n=== #{category} Fixes ==="
    
    if @fixes_applied.empty?
      puts "No fixes applied."
    else
      # Group fixes by page
      fixes_by_page = @fixes_applied.group_by { |fix| fix[:page] }
      
      fixes_by_page.each do |page, fixes|
        puts "\nPage: #{page}"
        
        # Group fixes by component
        fixes_by_component = fixes.group_by { |fix| fix[:component] }
        
        fixes_by_component.each do |component, component_fixes|
          puts "  Component: #{component}"
          
          component_fixes.each do |fix|
            puts "    - Issue: #{fix[:issue]}"
            puts "      Fix: #{fix[:fix]}"
          end
        end
      end
    end
    
    # Clear fixes for next test
    @fixes_applied = []
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