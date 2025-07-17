# frozen_string_literal: true

module AccessibilityTestHelper
  # Accessibility testing utilities for UI components
  # Provides helpers for testing WCAG 2.1 AA compliance
  
  # Color contrast ratios for WCAG compliance
  WCAG_AA_NORMAL_RATIO = 4.5
  WCAG_AA_LARGE_RATIO = 3.0
  WCAG_AAA_NORMAL_RATIO = 7.0
  WCAG_AAA_LARGE_RATIO = 4.5
  
  def assert_accessible_name(selector)
    element = page.find(selector)
    
    # Check for accessible name via various methods
    accessible_name = get_accessible_name(element)
    
    assert_not_empty accessible_name.strip,
                     "Element #{selector} must have an accessible name (aria-label, aria-labelledby, or text content)"
  end
  
  def assert_proper_heading_hierarchy
    headings = page.all('h1, h2, h3, h4, h5, h6').map do |heading|
      heading.tag_name.gsub('h', '').to_i
    end
    
    return if headings.empty?
    
    # Check that headings start with h1
    assert_equal 1, headings.first, "Page should start with h1, found h#{headings.first}"
    
    # Check that heading levels don't skip (e.g., h1 -> h3)
    headings.each_cons(2) do |current, next_heading|
      level_jump = next_heading - current
      assert level_jump <= 1, "Heading hierarchy skips from h#{current} to h#{next_heading}"
    end
  end
  
  def assert_keyboard_navigable(selector)
    element = page.find(selector)
    
    # Check if element is focusable
    is_focusable = page.evaluate_script(
      "arguments[0].tabIndex >= 0 || ['A', 'BUTTON', 'INPUT', 'SELECT', 'TEXTAREA'].includes(arguments[0].tagName)",
      element.native
    )
    
    if is_focusable
      # Test keyboard focus
      element.send_keys(:tab)
      focused_element = page.evaluate_script("document.activeElement")
      
      assert_equal element.native, focused_element,
                   "Element #{selector} should be keyboard focusable"
      
      # Check for visible focus indicator
      assert_visible_focus_indicator(element)
    end
  end
  
  def assert_sufficient_color_contrast(selector, level: :aa)
    element = page.find(selector)
    
    # Get computed colors
    styles = page.evaluate_script(
      "window.getComputedStyle(arguments[0])",
      element.native
    )
    
    foreground = parse_color(styles['color'])
    background = parse_color(styles['background-color'])
    
    # Calculate contrast ratio
    contrast_ratio = calculate_contrast_ratio(foreground, background)
    
    # Determine required ratio based on text size and level
    font_size = parse_font_size(styles['font-size'])
    is_large_text = font_size >= 18 || (font_size >= 14 && styles['font-weight'].to_i >= 700)
    
    required_ratio = case level
                     when :aa
                       is_large_text ? WCAG_AA_LARGE_RATIO : WCAG_AA_NORMAL_RATIO
                     when :aaa
                       is_large_text ? WCAG_AAA_LARGE_RATIO : WCAG_AAA_NORMAL_RATIO
                     end
    
    assert contrast_ratio >= required_ratio,
           "Insufficient color contrast for #{selector}: #{contrast_ratio.round(2)} (required: #{required_ratio})"
  end
  
  def assert_proper_form_labels
    # Check all form inputs have proper labels
    inputs = page.all('input, select, textarea')
    
    inputs.each do |input|
      input_id = input[:id]
      input_type = input[:type]
      
      # Skip hidden inputs
      next if input_type == 'hidden'
      
      has_label = page.has_selector?("label[for='#{input_id}']") if input_id
      has_aria_label = input['aria-label'].present?
      has_aria_labelledby = input['aria-labelledby'].present?
      
      assert(has_label || has_aria_label || has_aria_labelledby,
             "Form input must have a proper label (label element, aria-label, or aria-labelledby)")
    end
  end
  
  def assert_proper_button_states
    buttons = page.all('button, [role="button"]')
    
    buttons.each do |button|
      # Check for proper disabled state
      if button[:disabled] || button['aria-disabled'] == 'true'
        # Disabled buttons should not be focusable
        tab_index = button[:tabindex]&.to_i || 0
        assert tab_index < 0, "Disabled buttons should not be focusable (tabindex should be -1)"
      end
      
      # Check for loading state accessibility
      if button['aria-busy'] == 'true'
        assert button['aria-label'].present? || button.text.present?,
               "Loading buttons should have accessible text or aria-label"
      end
    end
  end
  
  def assert_proper_aria_attributes(selector)
    element = page.find(selector)
    
    # Check for common ARIA attribute issues
    aria_labelledby = element['aria-labelledby']
    if aria_labelledby.present?
      referenced_elements = aria_labelledby.split.map { |id| page.find("##{id}", visible: false) }
      assert referenced_elements.all?(&:present?),
             "aria-labelledby references non-existent elements"
    end
    
    aria_describedby = element['aria-describedby']
    if aria_describedby.present?
      referenced_elements = aria_describedby.split.map { |id| page.find("##{id}", visible: false) }
      assert referenced_elements.all?(&:present?),
             "aria-describedby references non-existent elements"
    end
  end
  
  def assert_no_accessibility_violations
    # Run basic accessibility checks
    assert_proper_heading_hierarchy
    assert_proper_form_labels
    assert_proper_button_states
    
    # Check for common violations
    assert_no_selector('[tabindex]:not([tabindex="-1"]):not([tabindex="0"])',
                       "Avoid positive tabindex values")
    
    assert_no_selector('img:not([alt])',
                       "All images must have alt attributes")
  end
  
  def with_reduced_motion
    page.execute_script(
      "document.documentElement.style.setProperty('--motion-reduce', 'reduce');" +
      "document.body.classList.add('reduce-motion');"
    )
    yield
  ensure
    page.execute_script(
      "document.documentElement.style.removeProperty('--motion-reduce');" +
      "document.body.classList.remove('reduce-motion');"
    )
  end
  
  def with_high_contrast
    page.execute_script("document.body.classList.add('high-contrast')")
    yield
  ensure
    page.execute_script("document.body.classList.remove('high-contrast')")
  end
  
  def simulate_screen_reader
    # Add screen reader simulation class for testing
    page.execute_script("document.body.classList.add('screen-reader-simulation')")
    yield
  ensure
    page.execute_script("document.body.classList.remove('screen-reader-simulation')")
  end
  
  private
  
  def get_accessible_name(element)
    # Try different methods to get accessible name
    aria_label = element['aria-label']
    return aria_label if aria_label.present?
    
    aria_labelledby = element['aria-labelledby']
    if aria_labelledby.present?
      referenced_text = aria_labelledby.split.map do |id|
        page.find("##{id}", visible: false).text
      end.join(' ')
      return referenced_text if referenced_text.present?
    end
    
    # For form elements, check associated label
    if element.tag_name.downcase.in?(%w[input select textarea])
      input_id = element[:id]
      if input_id.present?
        label = page.find("label[for='#{input_id}']", visible: false)
        return label.text if label.present?
      end
    end
    
    # Fall back to element text content
    element.text
  end
  
  def assert_visible_focus_indicator(element)
    # Focus the element
    element.click
    
    # Check for visible focus styles
    styles = page.evaluate_script(
      "window.getComputedStyle(arguments[0], ':focus')",
      element.native
    )
    
    has_outline = styles['outline'] != 'none' && styles['outline-width'] != '0px'
    has_box_shadow = styles['box-shadow'] != 'none'
    has_border_change = styles['border'] != page.evaluate_script(
      "window.getComputedStyle(arguments[0])",
      element.native
    )['border']
    
    assert(has_outline || has_box_shadow || has_border_change,
           "Element must have visible focus indicator")
  end
  
  def parse_color(color_string)
    # Parse RGB color string to array [r, g, b]
    if color_string.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/)
      [$1.to_i, $2.to_i, $3.to_i]
    elsif color_string.match(/rgba\((\d+),\s*(\d+),\s*(\d+),\s*[\d.]+\)/)
      [$1.to_i, $2.to_i, $3.to_i]
    else
      [0, 0, 0] # Default to black if parsing fails
    end
  end
  
  def parse_font_size(font_size_string)
    # Parse font size to pixels
    if font_size_string.end_with?('px')
      font_size_string.to_f
    elsif font_size_string.end_with?('em')
      font_size_string.to_f * 16 # Assume 16px base
    else
      16 # Default
    end
  end
  
  def calculate_contrast_ratio(color1, color2)
    # Calculate WCAG contrast ratio
    l1 = relative_luminance(color1)
    l2 = relative_luminance(color2)
    
    lighter = [l1, l2].max
    darker = [l1, l2].min
    
    (lighter + 0.05) / (darker + 0.05)
  end
  
  def relative_luminance(rgb)
    # Calculate relative luminance for WCAG contrast
    r, g, b = rgb.map do |component|
      component = component / 255.0
      component <= 0.03928 ? component / 12.92 : ((component + 0.055) / 1.055) ** 2.4
    end
    
    0.2126 * r + 0.7152 * g + 0.0722 * b
  end
end