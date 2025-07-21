# frozen_string_literal: true

module Ui
  # Preview for the Skeleton component
  # 
  # ## Usage Guidelines
  # 
  # - Use skeleton components to indicate loading states
  # - Match skeleton dimensions to the expected content dimensions
  # - Group related skeleton elements to represent content structure
  # - Use consistent skeleton styling throughout the application
  # - Consider using skeleton animations to indicate loading
  # 
  # ## Accessibility Considerations
  # 
  # - ARIA attributes: Use aria-busy="true" on container elements
  # - Screen reader support: Provide text for screen readers indicating loading state
  # - Animation: Respect reduced motion preferences
  # - Focus management: Ensure proper focus handling when content loads
  # 
  # ## Theme Support
  # 
  # This component uses CSS variables for theming and works in both light and dark modes.
  # All colors are derived from the theme tokens to ensure consistency.
  class SkeletonComponentPreview < ViewComponent::Preview
    # @!group Variants
    
    # @label Default
    def default
      render(Ui::SkeletonComponent.new(width: "100%", height: "20px"))
    end

    # @label Primary
    def primary
      render(Ui::SkeletonComponent.new(width: "100%", height: "20px", variant: :primary))
    end

    # @label Success
    def success
      render(Ui::SkeletonComponent.new(width: "100%", height: "20px", variant: :success))
    end

    # @label Warning
    def warning
      render(Ui::SkeletonComponent.new(width: "100%", height: "20px", variant: :warning))
    end

    # @label Destructive
    def destructive
      render(Ui::SkeletonComponent.new(width: "100%", height: "20px", variant: :destructive))
    end
    # @!endgroup

    # @!group Features

    # @label Custom Dimensions
    def custom_dimensions
      render_with_template
    end

    # @label Rounded
    def rounded
      render(Ui::SkeletonComponent.new(width: "48px", height: "48px", rounded: true))
    end

    # @label Without Animation
    def without_animation
      render(Ui::SkeletonComponent.new(width: "100%", height: "20px", animate: false))
    end

    # @label Content Placeholder
    def content_placeholder
      render_with_template
    end

    # @label Card Placeholder
    def card_placeholder
      render_with_template
    end

    # @label Table Placeholder
    def table_placeholder
      render_with_template
    end
    # @!endgroup

    # @!group Theme Examples
    
    # @label Light and Dark Theme
    def theme_examples
      render_with_template(locals: {
        component: Ui::SkeletonComponent.new(width: "100%", height: "20px")
      })
    end
    # @!endgroup

    # @!group Accessibility Examples
    
    # @label Screen Reader Support
    def screen_reader_support
      render_with_template
    end

    # @label Reduced Motion
    def reduced_motion
      render_with_template
    end
    # @!endgroup
  end
end