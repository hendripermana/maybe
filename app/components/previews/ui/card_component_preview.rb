# frozen_string_literal: true

module Ui
  # Preview for the Card component
  # 
  # ## Usage Guidelines
  # 
  # - Use cards to group related content and actions
  # - Use the appropriate variant based on the card's purpose and prominence
  # - Use consistent card sizing within the same section or grid
  # - Leverage header and footer slots for actions and metadata
  # - Ensure proper spacing within cards (padding and content spacing)
  # 
  # ## Accessibility Considerations
  # 
  # - Heading hierarchy: Use proper heading levels within cards
  # - Interactive cards: Ensure proper focus management for clickable cards
  # - Color contrast: All text meets WCAG AA contrast requirements
  # - Keyboard navigation: Interactive elements within cards are keyboard accessible
  # 
  # ## Theme Support
  # 
  # This component uses CSS variables for theming and works in both light and dark modes.
  # All colors are derived from the theme tokens to ensure consistency.
  class CardComponentPreview < ViewComponent::Preview
    # @!group Variants
    
    # @label Default
    def default
      render(Ui::CardComponent.new(title: "Card Title")) do
        "This is a default card with standard styling."
      end
    end

    # @label Elevated
    def elevated
      render(Ui::CardComponent.new(title: "Elevated Card", variant: :elevated)) do
        "This card has enhanced elevation with a more prominent shadow."
      end
    end

    # @label Outlined
    def outlined
      render(Ui::CardComponent.new(title: "Outlined Card", variant: :outlined)) do
        "This card uses a border instead of a shadow for definition."
      end
    end

    # @label Ghost
    def ghost
      render(Ui::CardComponent.new(title: "Ghost Card", variant: :ghost)) do
        "This card has no background or border, useful for subtle grouping."
      end
    end

    # @label Interactive
    def interactive
      render(Ui::CardComponent.new(
        title: "Interactive Card",
        variant: :interactive,
        href: "#"
      )) do
        "This entire card is clickable. Hover to see the effect."
      end
    end
    # @!endgroup

    # @!group Sizes

    # @label Small
    def small
      render(Ui::CardComponent.new(title: "Small Card", size: :sm)) do
        "This card has compact padding (p-4)."
      end
    end

    # @label Medium (Default)
    def medium
      render(Ui::CardComponent.new(title: "Medium Card", size: :md)) do
        "This card has standard padding (p-6)."
      end
    end

    # @label Large
    def large
      render(Ui::CardComponent.new(title: "Large Card", size: :lg)) do
        "This card has spacious padding (p-8)."
      end
    end

    # @label Extra Large
    def extra_large
      render(Ui::CardComponent.new(title: "Extra Large Card", size: :xl)) do
        "This card has maximum padding (p-10)."
      end
    end
    # @!endgroup

    # @!group Features

    # @label With Header and Footer
    def with_header_and_footer
      render_with_template(locals: {
        component: Ui::CardComponent.new(title: "Card with Header and Footer")
      })
    end

    # @label With Description
    def with_description
      render(Ui::CardComponent.new(
        title: "Card with Description",
        description: "This is a description that appears below the title."
      )) do
        "This card includes a description below the title."
      end
    end

    # @label With Custom Header
    def with_custom_header
      render_with_template(locals: {
        component: Ui::CardComponent.new
      })
    end

    # @label With Icon
    def with_icon
      render(Ui::CardComponent.new(
        title: "Card with Icon",
        icon: "info-circle"
      )) do
        "This card includes an icon next to the title."
      end
    end

    # @label Full Width
    def full_width
      render(Ui::CardComponent.new(
        title: "Full Width Card",
        full_width: true
      )) do
        "This card takes up the full width of its container."
      end
    end
    # @!endgroup

    # @!group Theme Examples
    
    # @label Light and Dark Theme
    def theme_examples
      render_with_template(locals: {
        component: Ui::CardComponent.new(title: "Theme-Aware Card")
      })
    end
    # @!endgroup

    # @!group Accessibility Examples
    
    # @label Keyboard Navigation
    def keyboard_navigation
      render_with_template(locals: {
        component: Ui::CardComponent.new(title: "Keyboard Navigation")
      })
    end

    # @label Screen Reader Support
    def screen_reader_support
      render_with_template(locals: {
        component: Ui::CardComponent.new(
          title: "Screen Reader Support",
          aria: { labelledby: "card-title", describedby: "card-desc" }
        )
      })
    end
    # @!endgroup
  end
end