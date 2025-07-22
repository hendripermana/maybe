module EnhancedAccessibilityTestHelper
  # Test for proper heading hierarchy with more detailed feedback
  def assert_proper_heading_hierarchy_with_details
    headings = page.all("h1, h2, h3, h4, h5, h6")
    
    # Create a map of heading levels
    heading_levels = headings.map do |heading|
      {
        level: heading.tag_name[1].to_i,
        text: heading.text.strip,
        element: heading
      }
    end
    
    # Check for proper hierarchy
    previous_level = 0
    heading_levels.each_with_index do |heading, index|
      if index == 0
        # First heading should be h1
        assert heading[:level] == 1, "First heading should be h1, found #{heading[:tag_name]} with text '#{heading[:text]}'"
      else
        # Subsequent headings should not skip levels
        if heading[:level] > previous_level
          assert heading[:level] == previous_level + 1, "Heading level skipped from h#{previous_level} to h#{heading[:level]} with text '#{heading[:text]}'"
        end
      end
      
      previous_level = heading[:level]
    end
    
    # Return heading structure for debugging
    heading_levels
  end
  
  # Test for proper landmark regions with detailed feedback
  def assert_proper_landmark_regions
    landmarks = page.all("main, nav, header, footer, aside, [role='search'], [role='complementary'], [role='banner'], [role='contentinfo']")
    
    # Check for required landmarks
    assert page.has_selector?("main"), "Page should have a main landmark"
    
    # Check for duplicate landmarks without differentiation
    landmark_roles = {
      "main" => 0,
      "navigation" => 0,
      "banner" => 0,
      "contentinfo" => 0
    }
    
    landmarks.each do |landmark|
      role = landmark[:role] || case landmark.tag_name
                               when "main" then "main"
                               when "nav" then "navigation"
                               when "header" then "banner"
                               when "footer" then "contentinfo"
                               when "aside" then "complementary"
                               end
      
      if landmark_roles.key?(role)
        landmark_roles[role] += 1
        
        # Check for aria-label or aria-labelledby if duplicate
        if landmark_roles[role] > 1
          assert landmark['aria-label'].present? || landmark['aria-labelledby'].present?,
                 "Duplicate #{role} landmark should have aria-label or aria-labelledby"
        end
      end
    end
    
    # Return landmark structure for debugging
    landmarks.map do |landmark|
      {
        tag: landmark.tag_name,
        role: landmark[:role],
        label: landmark['aria-label'] || (landmark['aria-labelledby'] ? "labelledby: #{landmark['aria-labelledby']}" : nil)
      }
    end
  end
  
  # Test for proper skip links
  def assert_has_skip_links
    assert page.has_selector?("a[href^='#']:not([href='#'])", text: /skip|jump/i),
           "Page should have skip links for keyboard users"
  end
  
  # Test for proper form error handling
  def assert_proper_form_error_handling
    # Find all form elements
    forms = page.all("form")
    
    forms.each do |form|
      # Find all inputs
      inputs = form.all("input, select, textarea")
      
      inputs.each do |input|
        # Check for error association
        input_id = input[:id]
        if input_id.present?
          error_element = page.all("[aria-describedby*='#{input_id}']").first
          
          if error_element.present?
            # Check that error message is properly associated
            error_id = error_element[:id]
            assert input['aria-describedby'].split.include?(error_id),
                   "Error message should be associated with input using aria-describedby"
          end
        end
      end
    end
  end
  
  # Test for proper focus management in modals
  def assert_proper_modal_focus_management
    # Find all modal triggers
    modal_triggers = page.all("[data-action='click->dialog#open'], [aria-haspopup='dialog']")
    
    modal_triggers.each do |trigger|
      # Open the modal
      trigger.click
      
      # Check if modal is open
      if page.has_selector?("[role='dialog'][aria-modal='true']")
        modal = find("[role='dialog'][aria-modal='true']")
        
        # Check if focus moves into the modal
        assert modal.has_selector?(":focus"),
               "Focus should move into the modal when opened"
        
        # Close the modal
        if modal.has_selector?("[data-action='click->dialog#close']")
          modal.find("[data-action='click->dialog#close']").click
          
          # Check if focus returns to trigger
          assert_equal trigger, page.find(":focus"),
                     "Focus should return to trigger when modal is closed"
        elsif page.has_selector?("[data-action='click->dialog#close']")
          find("[data-action='click->dialog#close']").click
          
          # Check if focus returns to trigger
          assert_equal trigger, page.find(":focus"),
                     "Focus should return to trigger when modal is closed"
        else
          # Try Escape key
          page.send_keys :escape
          
          # Check if focus returns to trigger
          assert_equal trigger, page.find(":focus"),
                     "Focus should return to trigger when modal is closed with Escape key"
        end
      end
    end
  end
  
  # Test for proper ARIA live regions
  def assert_proper_aria_live_regions
    # Find all live regions
    live_regions = page.all("[aria-live]")
    
    live_regions.each do |region|
      # Check for valid aria-live values
      assert %w[polite assertive off].include?(region['aria-live']),
             "aria-live attribute should have value 'polite', 'assertive', or 'off'"
      
      # Check for proper use of aria-atomic
      if region['aria-atomic'].present?
        assert %w[true false].include?(region['aria-atomic']),
               "aria-atomic attribute should have value 'true' or 'false'"
      end
      
      # Check for proper use of aria-relevant
      if region['aria-relevant'].present?
        valid_values = %w[additions removals text all]
        region_values = region['aria-relevant'].split
        
        region_values.each do |value|
          assert valid_values.include?(value),
                 "aria-relevant attribute should only contain values from: #{valid_values.join(', ')}"
        end
      end
    end
  end
  
  # Test for proper use of ARIA in custom widgets
  def assert_proper_aria_in_custom_widgets
    # Test tablist widgets
    if page.has_selector?("[role='tablist']")
      tablists = page.all("[role='tablist']")
      
      tablists.each do |tablist|
        # Find all tabs
        tabs = tablist.all("[role='tab']")
        
        tabs.each do |tab|
          # Check for aria-controls
          assert tab['aria-controls'].present?,
                 "Tab should have aria-controls attribute"
          
          # Check for aria-selected
          assert tab['aria-selected'].present?,
                 "Tab should have aria-selected attribute"
          
          # Check that controlled element exists
          tab_panel_id = tab['aria-controls']
          assert page.has_selector?("##{tab_panel_id}"),
                 "Tab panel with ID #{tab_panel_id} should exist"
          
          # Check that tab panel has correct role
          tab_panel = find("##{tab_panel_id}")
          assert tab_panel[:role] == "tabpanel",
                 "Element controlled by tab should have role='tabpanel'"
          
          # Check for proper labelling
          assert tab_panel['aria-labelledby'] == tab[:id],
                 "Tab panel should have aria-labelledby referencing the tab"
        end
      end
    end
    
    # Test combobox widgets
    if page.has_selector?("[role='combobox']")
      comboboxes = page.all("[role='combobox']")
      
      comboboxes.each do |combobox|
        # Check for aria-expanded
        assert combobox['aria-expanded'].present?,
               "Combobox should have aria-expanded attribute"
        
        # Check for aria-controls
        assert combobox['aria-controls'].present?,
               "Combobox should have aria-controls attribute"
        
        # Check that controlled element exists
        listbox_id = combobox['aria-controls']
        assert page.has_selector?("##{listbox_id}"),
               "Listbox with ID #{listbox_id} should exist"
        
        # Check that listbox has correct role
        listbox = find("##{listbox_id}")
        assert %w[listbox tree grid dialog].include?(listbox[:role]),
               "Element controlled by combobox should have appropriate role"
      end
    end
  end
  
  # Test for proper reduced motion support
  def assert_proper_reduced_motion_support
    # Add prefers-reduced-motion media query
    page.execute_script(<<~JS)
      document.documentElement.style.setProperty('--prefers-reduced-motion', 'reduce');
      
      // Add a class to simulate prefers-reduced-motion
      document.documentElement.classList.add('reduced-motion');
    JS
    
    # Find all animated elements
    animated_elements = page.all("[class*='animate-'], [class*='transition-']")
    
    # Check if animations are disabled
    animated_elements.each do |element|
      computed_style = page.evaluate_script(<<~JS)
        window.getComputedStyle(document.querySelector('[data-testid="#{element['data-testid']}"]')).animation
      JS
      
      # This is a simplified check - in a real test, you would need to check more thoroughly
      assert computed_style == "none" || computed_style == "",
             "Elements should respect prefers-reduced-motion"
    end
    
    # Reset
    page.execute_script(<<~JS)
      document.documentElement.style.removeProperty('--prefers-reduced-motion');
      document.documentElement.classList.remove('reduced-motion');
    JS
  end
end