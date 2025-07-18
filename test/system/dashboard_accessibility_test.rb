require "application_system_test_case"

class DashboardAccessibilityTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "dashboard components meet WCAG 2.1 AA standards" do
    visit root_path
    
    # Test both themes for accessibility compliance
    test_both_themes do
      # Check heading hierarchy
      assert_proper_heading_hierarchy
      
      # Check color contrast for key components
      key_components = [
        ".dashboard-card",
        ".chart-container",
        ".dashboard-header",
        ".btn-modern-primary",
        ".btn-modern-secondary"
      ]
      
      key_components.each do |selector|
        if has_selector?(selector)
          assert_sufficient_color_contrast(selector)
        end
      end
      
      # Check for proper ARIA attributes
      aria_elements = all("[aria-label], [aria-labelledby], [aria-describedby]")
      aria_elements.each do |element|
        assert_proper_aria_attributes(element)
      end
    end
  end

  test "dashboard components are keyboard navigable" do
    visit root_path
    
    # Test keyboard navigation through interactive elements
    interactive_elements = [
      "button",
      "a",
      "[role='button']",
      "[tabindex='0']",
      ".btn-modern-primary",
      ".btn-modern-secondary"
    ]
    
    # Verify tab order is logical
    tab_order = []
    
    # Press tab multiple times to navigate through elements
    10.times do
      page.send_keys(:tab)
      focused_element = page.evaluate_script("document.activeElement")
      tab_order << focused_element if focused_element
    end
    
    # Verify we can tab through elements
    assert tab_order.length > 1, "Tab navigation should move through multiple elements"
    
    # Test individual interactive elements
    interactive_elements.each do |selector|
      if has_selector?(selector)
        elements = all(selector)
        elements.each do |element|
          assert_keyboard_navigable(element)
        end
      end
    end
  end

  test "dashboard components work with screen readers" do
    visit root_path
    
    # Test screen reader compatibility
    simulate_screen_reader do
      # Check for proper accessible names on interactive elements
      interactive_elements = all("button, a, [role='button'], input, select")
      interactive_elements.each do |element|
        assert_accessible_name(element)
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
      
      # Check for proper ARIA roles
      role_elements = all("[role]")
      role_elements.each do |element|
        role = element[:role]
        assert ["button", "dialog", "navigation", "tab", "tablist", "tabpanel", "menu", "menuitem"].include?(role),
               "Element has invalid or unsupported ARIA role: #{role}"
      end
    end
  end

  test "dashboard components support reduced motion preferences" do
    visit root_path
    
    # Test with reduced motion preference
    with_reduced_motion do
      # Check that animations are disabled or reduced
      if has_selector?(".chart-container")
        # Verify chart animations respect reduced motion
        chart_element = find(".chart-container")
        
        # Check for reduced motion CSS class
        assert page.has_css?(".reduce-motion"), "Reduced motion class should be applied"
        
        # If there are specific animations, check they're disabled
        if has_selector?(".chart-animation")
          animation_duration = page.evaluate_script(
            "getComputedStyle(document.querySelector('.chart-animation')).animationDuration"
          )
          
          assert ["0s", "none"].include?(animation_duration),
                 "Animations should be disabled with reduced motion preference"
        end
      end
    end
  end

  test "dashboard components support high contrast mode" do
    visit root_path
    
    # Test with high contrast mode
    with_high_contrast do
      # Check that high contrast styles are applied
      assert page.has_css?(".high-contrast"), "High contrast class should be applied"
      
      # Test key components for sufficient contrast
      key_components = [
        ".dashboard-card",
        ".chart-container",
        ".dashboard-header",
        ".btn-modern-primary"
      ]
      
      key_components.each do |selector|
        if has_selector?(selector)
          # Use stricter AAA contrast requirements for high contrast mode
          assert_sufficient_color_contrast(selector, level: :aaa)
        end
      end
    end
  end
end