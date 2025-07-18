module ResponsiveTransactionsTestHelper
  # Helper method to test in both themes
  def test_both_themes
    # Test in light theme
    ensure_theme("light")
    yield
    
    # Test in dark theme
    ensure_theme("dark")
    yield
  end
  
  # Helper method to ensure a specific theme is active
  def ensure_theme(theme)
    # Check current theme
    current_theme = page.evaluate_script(
      "document.documentElement.getAttribute('data-theme')"
    )
    
    # Switch theme if needed
    if current_theme != theme
      # Find theme toggle button
      if has_selector?("button[aria-label='Toggle theme']")
        find("button[aria-label='Toggle theme']").click
      else
        # Set theme directly if button not found
        page.execute_script(
          "document.documentElement.setAttribute('data-theme', '#{theme}')"
        )
      end
      
      # Verify theme changed
      new_theme = page.evaluate_script(
        "document.documentElement.getAttribute('data-theme')"
      )
      assert_equal theme, new_theme, "Theme should be changed to #{theme}"
    end
  end
  
  # Helper method to check proper heading hierarchy
  def assert_proper_heading_hierarchy
    # Get all headings
    headings = all("h1, h2, h3, h4, h5, h6", visible: true)
    
    # Skip if no headings
    return if headings.empty?
    
    # Check heading levels
    previous_level = 0
    headings.each do |heading|
      # Get heading level
      level = heading.tag_name[1].to_i
      
      # First heading can be any level
      if previous_level == 0
        previous_level = level
        next
      end
      
      # Heading levels should not skip more than one level
      assert level <= previous_level + 1, 
             "Heading levels should not skip more than one level (found h#{previous_level} followed by h#{level})"
      
      previous_level = level
    end
  end
  
  # Helper method to check proper ARIA attributes
  def assert_proper_aria_attributes(element)
    # Check for proper ARIA labels
    if element[:aria_label].present?
      assert element[:aria_label].strip.present?, "ARIA label should not be empty"
    end
    
    # Check for proper ARIA labelledby
    if element[:aria_labelledby].present?
      labelledby_id = element[:aria_labelledby]
      assert has_selector?("##{labelledby_id}"), "Element referenced by aria-labelledby should exist"
    end
    
    # Check for proper ARIA describedby
    if element[:aria_describedby].present?
      describedby_id = element[:aria_describedby]
      assert has_selector?("##{describedby_id}"), "Element referenced by aria-describedby should exist"
    end
  end
  
  # Helper method to check proper form labels
  def assert_proper_form_labels(form_selector = nil)
    # Find all form controls
    selector = form_selector ? "#{form_selector} input, #{form_selector} select, #{form_selector} textarea" : "input, select, textarea"
    controls = all(selector, visible: true)
    
    controls.each do |control|
      next if control[:type] == "hidden" || control[:type] == "submit" || control[:type] == "button"
      
      assert_has_label(control)
    end
  end
  
  # Helper method to check if a control has a label
  def assert_has_label(control)
    # Check if control has a label
    has_label = false
    
    # Check for label element
    if control[:id].present?
      has_label ||= has_selector?("label[for='#{control[:id]}']")
    end
    
    # Check for aria-label
    has_label ||= control[:aria_label].present?
    
    # Check for aria-labelledby
    has_label ||= control[:aria_labelledby].present?
    
    # Check for parent label
    has_label ||= control.has_ancestor?("label")
    
    # Check for placeholder (not ideal but better than nothing)
    has_label ||= control[:placeholder].present?
    
    assert has_label, "Form control should have an accessible label"
  end
  
  # Helper method to check color contrast
  def assert_color_contrast(text_color, bg_color)
    # Convert colors to simple RGB values
    text_rgb = color_to_rgb(text_color)
    bg_rgb = color_to_rgb(bg_color)
    
    # Check that colors are different enough
    assert text_rgb != bg_rgb, "Text color should contrast with background color"
    
    # Simple luminance difference check (very basic)
    text_luminance = calculate_luminance(text_rgb)
    bg_luminance = calculate_luminance(bg_rgb)
    
    luminance_diff = (text_luminance - bg_luminance).abs
    assert luminance_diff > 0.2, "Text and background should have sufficient luminance difference"
  end
  
  # Helper method to convert color to RGB
  def color_to_rgb(color)
    # Convert various color formats to RGB array
    if color.start_with?("rgb")
      # Extract RGB values from rgb(r, g, b) or rgba(r, g, b, a)
      color.gsub(/rgba?\(|\)/, "").split(",").map(&:strip).take(3).map(&:to_i)
    elsif color.start_with?("#")
      # Convert hex to RGB
      [
        color[1..2].to_i(16),
        color[3..4].to_i(16),
        color[5..6].to_i(16)
      ]
    else
      # Unknown format, return as is
      color
    end
  end
  
  # Helper method to calculate luminance
  def calculate_luminance(rgb)
    # Simple relative luminance calculation (approximation)
    # Formula: 0.299*R + 0.587*G + 0.114*B (normalized to 0-1)
    r, g, b = rgb
    (0.299 * r + 0.587 * g + 0.114 * b) / 255
  end
  
  # Helper method to check accessible name
  def assert_accessible_name(element)
    # Get accessible name
    accessible_name = element.text.presence || 
                     element[:aria_label].presence || 
                     (element[:aria_labelledby] && find("##{element[:aria_labelledby]}")&.text)
    
    # Check if element has accessible name
    assert accessible_name.present?, "Element should have accessible name"
  end
  
  # Helper method to create multiple transactions for pagination testing
  def create_multiple_transactions(count)
    account = Current.user.family.accounts.first
    
    count.times do |i|
      Entry.create!(
        account: account,
        name: "Test Transaction #{i}",
        amount: -10.0,
        date: Date.current - i.days,
        entryable_type: "Transaction",
        entryable_attributes: {
          category_id: Current.user.family.categories.first.id
        }
      )
    end
  end
  
  # Helper method to take component screenshot
  def take_component_screenshot(name, theme: nil)
    theme ||= page.evaluate_script("document.documentElement.getAttribute('data-theme')")
    screenshot_name = "#{name}_#{theme}"
    page.save_screenshot(Rails.root.join("tmp/screenshots/#{screenshot_name}.png"))
  end
end