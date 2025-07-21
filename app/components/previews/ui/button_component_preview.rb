# frozen_string_literal: true

module Ui
  # Preview for the Button component
  # 
  # ## Usage Guidelines
  # 
  # - Use primary buttons for main actions on a page
  # - Use secondary buttons for alternative actions
  # - Use destructive buttons for dangerous actions (delete, remove)
  # - Use ghost buttons for subtle actions within a dense UI
  # - Use outline buttons when you need a less prominent option
  # - Use link buttons for navigation-like actions
  # 
  # ## Accessibility Considerations
  # 
  # - Keyboard navigation: Buttons are natively focusable and activatable
  # - Screen reader support: Uses semantic button element with proper labels
  # - Color contrast: All button variants meet WCAG AA contrast requirements
  # - Disabled state: Visually distinct and properly communicated to screen readers
  # 
  # ## Theme Support
  # 
  # This component uses CSS variables for theming and works in both light and dark modes.
  # All colors are derived from the theme tokens to ensure consistency.
  class ButtonComponentPreview < ViewComponent::Preview
    # @!group Variants
    
    # @label Primary
    def primary
      render(Ui::ButtonComponent.new(variant: :primary)) do
        "Primary Button"
      end
    end

    # @label Secondary
    def secondary
      render(Ui::ButtonComponent.new(variant: :secondary)) do
        "Secondary Button"
      end
    end

    # @label Destructive
    def destructive
      render(Ui::ButtonComponent.new(variant: :destructive)) do
        "Destructive Button"
      end
    end

    # @label Outline
    def outline
      render(Ui::ButtonComponent.new(variant: :outline)) do
        "Outline Button"
      end
    end

    # @label Ghost
    def ghost
      render(Ui::ButtonComponent.new(variant: :ghost)) do
        "Ghost Button"
      end
    end

    # @label Link
    def link
      render(Ui::ButtonComponent.new(variant: :link)) do
        "Link Button"
      end
    end
    # @!endgroup

    # @!group Sizes

    # @label Small
    def small
      render(Ui::ButtonComponent.new(size: :sm)) do
        "Small Button"
      end
    end

    # @label Medium (Default)
    def medium
      render(Ui::ButtonComponent.new(size: :md)) do
        "Medium Button"
      end
    end

    # @label Large
    def large
      render(Ui::ButtonComponent.new(size: :lg)) do
        "Large Button"
      end
    end

    # @label Extra Large
    def extra_large
      render(Ui::ButtonComponent.new(size: :xl)) do
        "Extra Large Button"
      end
    end
    # @!endgroup

    # @!group Features

    # @label With Icon
    def with_icon
      render(Ui::ButtonComponent.new(icon: "plus")) do
        "Button with Icon"
      end
    end

    # @label Loading State
    def loading
      render(Ui::ButtonComponent.new(loading: true)) do
        "Loading Button"
      end
    end

    # @label Disabled
    def disabled
      render(Ui::ButtonComponent.new(disabled: true)) do
        "Disabled Button"
      end
    end

    # @label Full Width
    def full_width
      render(Ui::ButtonComponent.new(full_width: true)) do
        "Full Width Button"
      end
    end

    # @label As Link
    def as_link
      render(Ui::ButtonComponent.new(href: "#")) do
        "Button as Link"
      end
    end
    # @!endgroup

    # @!group Theme Examples
    
    # @label Light and Dark Theme
    def theme_examples
      render_with_template(locals: {
        component: Ui::ButtonComponent.new(variant: :primary)
      })
    end
    # @!endgroup

    # @!group Accessibility Examples
    
    # @label Keyboard Navigation
    def keyboard_navigation
      render_with_template(locals: {
        component: Ui::ButtonComponent.new(variant: :primary)
      })
    end

    # @label Screen Reader Support
    def screen_reader_support
      render_with_template(locals: {
        component: Ui::ButtonComponent.new(variant: :primary)
      })
    end
    # @!endgroup
  end
end