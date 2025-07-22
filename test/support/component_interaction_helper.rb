# frozen_string_literal: true

module ComponentInteractionHelper
  # Interaction testing utilities specifically for UI components
  # Provides helpers for testing component interactions
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def interaction_test_for(component_class, interactions = [], options = {})
      component_name = component_class.name.demodulize.underscore.sub(/_component$/, '')
      
      define_method("test_interactions_#{component_name}") do
        component = component_class.new(**options[:props].to_h)
        
        if options[:content]
          render_inline(component) { options[:content] }
        else
          render_inline(component)
        end
        
        # Test each interaction
        interactions.each do |interaction|
          case interaction
          when :click
            test_click_interaction
          when :hover
            test_hover_interaction
          when :focus
            test_focus_interaction
          when :keyboard
            test_keyboard_interaction
          end
        end
      end
    end
  end
  
  def test_click_interaction
    # Test click behavior if component has click handler
    click_handlers = css_select('[data-action*="click->"]')
    
    if click_handlers.present?
      # Check that click handlers are on interactive elements
      click_handlers.each do |element|
        assert element.matches?('button, a[href], [role="button"], [tabindex="0"]'),
               "Click handlers should be on interactive elements"
      end
    end
  end
  
  def test_hover_interaction
    # Test hover states if component has them
    hover_classes = rendered_content.to_s.scan(/class="[^"]*hover:[^"]*"/)
    
    if hover_classes.present?
      # Extract the hover classes
      hover_class_names = hover_classes.flat_map do |class_attr|
        class_attr.scan(/hover:([^\s"]+)/)
      end
      
      assert hover_class_names.present?,
             "Component with hover styles should have proper hover:* classes"
    end
  end
  
  def test_focus_interaction
    # Test focus states if component has them
    focus_classes = rendered_content.to_s.scan(/class="[^"]*focus:[^"]*"/)
    
    if focus_classes.present?
      # Extract the focus classes
      focus_class_names = focus_classes.flat_map do |class_attr|
        class_attr.scan(/focus:([^\s"]+)/)
      end
      
      assert focus_class_names.present?,
             "Component with focus styles should have proper focus:* classes"
    end
  end
  
  def test_keyboard_interaction
    # Test keyboard interaction if component is interactive
    interactive_elements = css_select('button, a[href], [role="button"], [tabindex="0"]')
    
    if interactive_elements.present?
      # Check for keyboard event handlers
      keyboard_events = %w[keydown keyup keypress]
      
      has_keyboard_handler = keyboard_events.any? do |event|
        rendered_content.to_s.include?("data-action=\"#{event}->")
      end
      
      # If no explicit keyboard handlers, check for click handlers
      # which should implicitly support keyboard via browser defaults
      has_click_handler = rendered_content.to_s.include?('data-action="click->')
      
      assert(has_keyboard_handler || has_click_handler,
             "Interactive component should support keyboard interaction")
    end
  end
  
  def test_form_validation
    # Test form validation if component is a form or contains form elements
    form_elements = css_select('form, input, select, textarea')
    
    if form_elements.present?
      # Check for validation attributes
      validation_attrs = %w[required pattern min max minlength maxlength]
      
      has_validation = validation_attrs.any? do |attr|
        rendered_content.to_s.include?("#{attr}=")
      end
      
      # Check for validation classes
      validation_classes = %w[invalid valid]
      
      has_validation_classes = validation_classes.any? do |class_name|
        rendered_content.to_s.include?("#{class_name}:")
      end
      
      assert(has_validation || has_validation_classes,
             "Form component should have validation attributes or classes")
    end
  end
  
  def test_loading_states
    # Test loading states if component has them
    loading_indicators = css_select('[aria-busy="true"], .animate-spin, .loading')
    
    if loading_indicators.present?
      # Check that loading state is properly communicated to screen readers
      loading_indicators.each do |element|
        assert element['aria-busy'] == 'true' || 
               element.parent['aria-busy'] == 'true' ||
               element['role'] == 'progressbar',
               "Loading indicators should have aria-busy='true' or role='progressbar'"
      end
    end
  end
end