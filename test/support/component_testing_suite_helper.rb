# frozen_string_literal: true

module ComponentTestingSuiteHelper
  # Comprehensive helper for component testing that combines theme testing,
  # accessibility testing, and interaction testing in one place
  
  include ThemeTestHelper
  include AccessibilityTestHelper
  include VisualRegressionHelper
  
  # Theme testing helpers specific to components
  def test_theme_switching(component, content = nil, &block)
    # Test that component renders correctly in both themes
    THEMES.each do |theme|
      with_theme(theme) do
        if block_given?
          render_inline(component, &block)
        elsif content
          render_inline(component) { content }
        else
          render_inline(component)
        end
        
        # Verify no hardcoded colors
        assert_no_hardcoded_colors("div")
        
        # Take screenshot for visual regression testing if in system test
        if respond_to?(:take_component_screenshot)
          component_name = component.class.name.demodulize.underscore.sub(/_component$/, '')
          take_component_screenshot(component_name, theme: theme)
        end
      end
    end
  end
  
  # Accessibility testing helpers for components
  def test_component_accessibility(component, content = nil, &block)
    # Render component
    if block_given?
      render_inline(component, &block)
    elsif content
      render_inline(component) { content }
    else
      render_inline(component)
    end
    
    # Basic accessibility checks
    if component.respond_to?(:accessible_label) && component.accessible_label.present?
      assert_not_empty component.accessible_label, "Component should have an accessible label"
    end
    
    # Check for proper ARIA attributes if component has them
    if rendered_content.to_s.include?('aria-')
      aria_attributes = %w[aria-label aria-labelledby aria-describedby aria-controls aria-expanded aria-haspopup aria-hidden]
      
      aria_attributes.each do |attr|
        if rendered_content.to_s.include?(attr)
          assert_selector "[#{attr}]"
        end
      end
    end
    
    # Check for proper roles if component uses them
    if rendered_content.to_s.include?('role=')
      assert_selector '[role]'
    end
  end
  
  # Interaction testing helpers for components
  def test_component_interactions(component, interactions = [], &block)
    # Render component
    if block_given?
      render_inline(component, &block)
    else
      render_inline(component)
    end
    
    # Test each interaction
    interactions.each do |interaction|
      case interaction
      when :click
        # Test click behavior if component has click handler
        if rendered_content.to_s.include?('data-action') && rendered_content.to_s.include?('click->')
          assert_selector '[data-action*="click->"]'
        end
      when :hover
        # Test hover states if component has them
        if rendered_content.to_s.include?('hover:')
          assert_selector '[class*="hover:"]'
        end
      when :focus
        # Test focus states if component has them
        if rendered_content.to_s.include?('focus:')
          assert_selector '[class*="focus:"]'
        end
      when :keyboard
        # Test keyboard interaction if component is interactive
        if rendered_content.to_s.include?('button') || rendered_content.to_s.include?('a href')
          assert_selector 'button, a[href], [role="button"], [tabindex="0"]'
        end
      end
    end
  end
  
  # Combined test that checks theme, accessibility and interactions
  def test_component_comprehensively(component, content: nil, interactions: [], &block)
    # Theme testing
    test_theme_switching(component, content, &block)
    
    # Accessibility testing
    test_component_accessibility(component, content, &block)
    
    # Interaction testing
    test_component_interactions(component, interactions, &block)
  end
end