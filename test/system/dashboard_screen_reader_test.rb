require "application_system_test_case"

class DashboardScreenReaderTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "dashboard has proper ARIA attributes for screen readers" do
    visit root_path
    
    # Test both themes for screen reader compatibility
    test_both_themes do
      # Check for proper ARIA landmarks
      assert_selector "[role='main']", count: 1, visible: true
      
      if has_selector?("nav")
        assert_selector "nav[aria-label], nav[aria-labelledby]", count: 1
      end
      
      # Check for proper heading structure
      assert_proper_heading_hierarchy
      
      # Check for proper button labels
      buttons = all("button, [role='button']")
      buttons.each do |button|
        assert_accessible_name(button)
      end
      
      # Check for proper image alt text
      images = all("img")
      images.each do |img|
        assert img[:alt].present?, "Images must have alt text for screen readers"
      end
      
      # Check for proper form labels if forms exist
      if has_selector?("form")
        assert_proper_form_labels
      end
      
      # Check for proper ARIA attributes on interactive elements
      interactive_elements = all("[aria-label], [aria-labelledby], [aria-describedby]")
      interactive_elements.each do |element|
        assert_proper_aria_attributes(element)
      end
      
      # Check for proper ARIA roles
      role_elements = all("[role]")
      role_elements.each do |element|
        role = element[:role]
        assert ["button", "dialog", "navigation", "tab", "tablist", "tabpanel", "menu", "menuitem", "main", "banner", "contentinfo"].include?(role),
               "Element has invalid or unsupported ARIA role: #{role}"
      end
    end
  end

  test "dashboard charts have proper screen reader alternatives" do
    visit root_path
    
    # Check for charts
    if has_selector?(".chart-container")
      charts = all(".chart-container")
      
      charts.each do |chart|
        # Check for accessible name
        assert_accessible_name(chart)
        
        # Check for aria-label or aria-labelledby
        assert chart["aria-label"].present? || chart["aria-labelledby"].present?,
               "Charts should have aria-label or aria-labelledby"
        
        # Check for textual alternative
        has_text_alternative = chart.has_selector?(".sr-only") || 
                               chart.has_selector?("[aria-hidden='true'] + .sr-only") ||
                               chart.has_selector?("figcaption")
        
        assert has_text_alternative,
               "Charts should have text alternative for screen readers"
      end
    end
    
    # Check Sankey chart specifically
    if has_selector?("#sankey-chart")
      sankey = find("#sankey-chart")
      
      # Check for accessible name
      assert_accessible_name(sankey)
      
      # Check for aria-label or aria-labelledby
      assert sankey["aria-label"].present? || sankey["aria-labelledby"].present?,
             "Sankey chart should have aria-label or aria-labelledby"
      
      # Check for textual summary
      assert has_selector?("#sankey-chart-summary.sr-only") || 
             has_selector?("[aria-describedby*='sankey-chart-summary']"),
             "Sankey chart should have textual summary for screen readers"
    end
  end

  test "dashboard interactive elements are screen reader accessible" do
    visit root_path
    
    # Test interactive elements
    interactive_elements = [
      "button",
      "a",
      "[role='button']",
      "input",
      "select",
      "[tabindex='0']"
    ]
    
    interactive_elements.each do |selector|
      if has_selector?(selector)
        elements = all(selector)
        
        elements.each do |element|
          # Check for accessible name
          assert_accessible_name(element)
          
          # Check for proper role
          if element.tag_name.downcase == "a" && element[:href].blank?
            assert element[:role] == "button",
                   "Links without href should have role='button'"
          end
          
          # Check for proper keyboard support
          if element[:role] == "button" || element.tag_name.downcase == "button"
            # Buttons should be activatable with Space and Enter
            assert element[:tabindex] != "-1" || element[:disabled] == "true",
                   "Interactive elements should be keyboard focusable unless disabled"
          end
        end
      end
    end
  end

  test "dashboard modals are screen reader accessible" do
    visit root_path
    
    # Check for fullscreen button
    if has_selector?("[data-action*='fullscreen']")
      # Open fullscreen modal
      find("[data-action*='fullscreen']").click
      
      # Verify modal appears
      assert_selector ".modal-fullscreen", visible: true
      
      # Check modal accessibility
      modal = find(".modal-fullscreen")
      
      # Check for proper ARIA attributes
      assert modal[:role] == "dialog", "Modal should have role='dialog'"
      assert modal["aria-modal"] == "true", "Modal should have aria-modal='true'"
      assert_accessible_name(modal)
      
      # Check for focus management
      focused_element = page.evaluate_script("document.activeElement")
      assert_equal modal.native, focused_element,
                   "Modal should receive focus when opened"
      
      # Check for proper close button
      assert_selector ".modal-close[aria-label]", visible: true
      
      # Close modal
      find(".modal-close").click
      
      # Verify modal closed
      assert_no_selector ".modal-fullscreen", visible: true
    end
  end

  test "dashboard has proper live regions for dynamic content" do
    visit root_path
    
    # Check for live regions
    live_regions = all("[aria-live]")
    
    live_regions.each do |region|
      # Check for proper aria-live value
      assert ["polite", "assertive", "off"].include?(region["aria-live"]),
             "aria-live must be 'polite', 'assertive', or 'off'"
      
      # Check for proper role if present
      if region[:role].present?
        assert ["status", "alert", "log", "timer", "marquee"].include?(region[:role]),
               "Live regions should have appropriate role"
      end
    end
    
    # Check for status messages
    status_regions = all("[role='status'], [role='alert']")
    
    status_regions.each do |region|
      # Status and alert regions should have aria-live if not implicit
      if region[:role] == "status" && region["aria-live"].blank?
        assert true, "role='status' has implicit aria-live='polite'"
      elsif region[:role] == "alert" && region["aria-live"].blank?
        assert true, "role='alert' has implicit aria-live='assertive'"
      else
        assert ["polite", "assertive"].include?(region["aria-live"]),
               "Status regions should have appropriate aria-live value"
      end
      
      # Check for accessible name
      assert_accessible_name(region)
    end
  end
end