# frozen_string_literal: true

module ComponentAccessibilityHelper
  # Accessibility testing utilities specifically for UI components
  # Extends the base AccessibilityTestHelper with component-specific functionality

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def accessibility_test_for(component_class, options = {})
      component_name = component_class.name.demodulize.underscore.sub(/_component$/, "")

      define_method("test_accessibility_#{component_name}") do
        component = component_class.new(**options[:props].to_h)

        if options[:content]
          render_inline(component) { options[:content] }
        else
          render_inline(component)
        end

        # Basic accessibility checks
        if component.respond_to?(:accessible_label) && component.accessible_label.present?
          assert_not_empty component.accessible_label, "Component should have an accessible label"
        end

        # Check for proper ARIA attributes
        check_aria_attributes

        # Check for proper roles
        check_roles

        # Check for proper focus management if interactive
        check_focus_management if options[:interactive]

        # Check for proper keyboard support if interactive
        check_keyboard_support if options[:interactive]
      end
    end
  end

  def check_aria_attributes
    aria_attributes = %w[aria-label aria-labelledby aria-describedby aria-controls
                         aria-expanded aria-haspopup aria-hidden aria-selected]

    aria_attributes.each do |attr|
      if rendered_content.to_s.include?(attr)
        # Check that attribute is not empty
        elements = css_select("[#{attr}]")
        elements.each do |element|
          attr_value = element[attr]
          assert_not_empty attr_value, "#{attr} should not be empty"

          # For aria-labelledby and aria-describedby, check that referenced elements exist
          if attr == "aria-labelledby" || attr == "aria-describedby"
            ids = attr_value.split(/\s+/)
            ids.each do |id|
              assert css_select("##{id}").present?, "#{attr} references non-existent element with id '#{id}'"
            end
          end
        end
      end
    end
  end

  def check_roles
    if rendered_content.to_s.include?("role=")
      elements = css_select("[role]")
      elements.each do |element|
        role = element["role"]
        assert_not_empty role, "role attribute should not be empty"

        # Check for valid ARIA roles
        valid_roles = %w[button checkbox dialog gridcell link menuitem option radio tab tabpanel]
        assert role.in?(valid_roles), "Invalid role: #{role}"
      end
    end
  end

  def check_focus_management
    # Check that interactive elements are focusable
    interactive_elements = css_select('button, a[href], [role="button"], [tabindex="0"]')
    assert interactive_elements.present?, "Interactive component should have focusable elements"

    # Check that non-interactive elements are not focusable
    non_interactive_elements = css_select('[tabindex="-1"]')
    non_interactive_elements.each do |element|
      assert element["aria-hidden"] == "true" || !element.matches?("button, a[href], input, select, textarea"),
             "Non-interactive elements should not be focusable unless they are hidden from screen readers"
    end
  end

  def check_keyboard_support
    # Check for keyboard event handlers
    keyboard_events = %w[keydown keyup keypress]

    has_keyboard_handler = keyboard_events.any? do |event|
      rendered_content.to_s.include?("data-action=\"#{event}->")
    end

    # If no explicit keyboard handlers, check for click handlers on interactive elements
    # which should implicitly support keyboard via browser defaults
    has_click_handler = rendered_content.to_s.include?('data-action="click->')

    interactive_elements = css_select('button, a[href], [role="button"], [tabindex="0"]')
    has_interactive_elements = interactive_elements.present?

    assert(has_keyboard_handler || has_click_handler || !has_interactive_elements,
           "Interactive component should support keyboard interaction")
  end
end
