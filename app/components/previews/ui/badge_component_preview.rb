# frozen_string_literal: true

module Ui
  # Preview for the Badge component
  # 
  # ## Usage Guidelines
  # 
  # - Use badges to highlight status, categories, or counts
  # - Choose appropriate variants based on the information being conveyed
  # - Keep badge text concise (1-2 words when possible)
  # - Use consistent badge styling throughout the application
  # - Consider using icons with badges to enhance visual recognition
  # 
  # ## Accessibility Considerations
  # 
  # - Color contrast: All badge text meets WCAG AA contrast requirements
  # - Text alternatives: Ensure badges have proper text for screen readers
  # - Don't rely on color alone: Use text or icons to convey information
  # - Size: Ensure badges are large enough to be readable
  # 
  # ## Theme Support
  # 
  # This component uses CSS variables for theming and works in both light and dark modes.
  # All colors are derived from the theme tokens to ensure consistency.
  class BadgeComponentPreview < ViewComponent::Preview
    # @!group Variants
    
    # @label Default
    def default
      render(Ui::BadgeComponent.new(variant: :default)) do
        "Default"
      end
    end

    # @label Primary
    def primary
      render(Ui::BadgeComponent.new(variant: :primary)) do
        "Primary"
      end
    end

    # @label Secondary
    def secondary
      render(Ui::BadgeComponent.new(variant: :secondary)) do
        "Secondary"
      end
    end

    # @label Success
    def success
      render(Ui::BadgeComponent.new(variant: :success)) do
        "Success"
      end
    end

    # @label Warning
    def warning
      render(Ui::BadgeComponent.new(variant: :warning)) do
        "Warning"
      end
    end

    # @label Destructive
    def destructive
      render(Ui::BadgeComponent.new(variant: :destructive)) do
        "Destructive"
      end
    end

    # @label Outline
    def outline
      render(Ui::BadgeComponent.new(variant: :outline)) do
        "Outline"
      end
    end
    # @!endgroup

    # @!group Sizes

    # @label Small
    def small
      render(Ui::BadgeComponent.new(size: :sm)) do
        "Small"
      end
    end

    # @label Medium (Default)
    def medium
      render(Ui::BadgeComponent.new(size: :md)) do
        "Medium"
      end
    end

    # @label Large
    def large
      render(Ui::BadgeComponent.new(size: :lg)) do
        "Large"
      end
    end
    # @!endgroup

    # @!group Features

    # @label With Icon
    def with_icon
      render_with_template
    end

    # @label With Count
    def with_count
      render_with_template
    end

    # @label As Link
    def as_link
      render(Ui::BadgeComponent.new(href: "#")) do
        "Badge Link"
      end
    end

    # @label Removable
    def removable
      render_with_template
    end

    # @label Status Indicators
    def status_indicators
      render_with_template
    end
    # @!endgroup

    # @!group Theme Examples
    
    # @label Light and Dark Theme
    def theme_examples
      render_with_template(locals: {
        component: Ui::BadgeComponent.new
      })
    end
    # @!endgroup

    # @!group Accessibility Examples
    
    # @label Screen Reader Support
    def screen_reader_support
      render_with_template
    end
    # @!endgroup
  end
end