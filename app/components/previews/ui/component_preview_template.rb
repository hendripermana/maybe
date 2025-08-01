# frozen_string_literal: true

module Ui
  # Preview for the ComponentName component
  #
  # ## Usage Guidelines
  #
  # - When to use this component
  # - When to use alternatives
  # - Best practices for implementation
  #
  # ## Accessibility Considerations
  #
  # - Keyboard navigation: Tab index and focus management
  # - Screen reader support: ARIA attributes
  # - Color contrast: Meets WCAG AA standards
  # - Reduced motion: Respects user preferences
  #
  # ## Theme Support
  #
  # This component uses CSS variables for theming and works in both light and dark modes.
  # All colors are derived from the theme tokens to ensure consistency.
  class ComponentNamePreview < ViewComponent::Preview
    # @!group Variants

    # @label Default
    def default
      render(Ui::ComponentNameComponent.new) do
        "Component content"
      end
    end

    # @label Primary
    def primary
      render(Ui::ComponentNameComponent.new(variant: :primary)) do
        "Component content"
      end
    end

    # Additional variants...
    # @!endgroup

    # @!group Sizes

    # @label Small
    def small
      render(Ui::ComponentNameComponent.new(size: :sm)) do
        "Component content"
      end
    end

    # @label Medium (Default)
    def medium
      render(Ui::ComponentNameComponent.new(size: :md)) do
        "Component content"
      end
    end

    # Additional sizes...
    # @!endgroup

    # @!group Features

    # @label With Feature
    def with_feature
      render(Ui::ComponentNameComponent.new(feature: true)) do
        "Component with feature"
      end
    end

    # Additional features...
    # @!endgroup

    # @!group Theme Examples

    # @label Light and Dark Theme
    def theme_examples
      render_with_template(locals: {
        component: Ui::ComponentNameComponent.new
      })
    end
    # @!endgroup

    # @!group Accessibility Examples

    # @label Keyboard Navigation
    def keyboard_navigation
      render_with_template(locals: {
        component: Ui::ComponentNameComponent.new
      })
    end

    # @label Screen Reader Support
    def screen_reader_support
      render_with_template(locals: {
        component: Ui::ComponentNameComponent.new
      })
    end
    # @!endgroup
  end
end
