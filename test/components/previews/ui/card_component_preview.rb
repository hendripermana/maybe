# frozen_string_literal: true

module Ui
  class CardComponentPreview < ViewComponent::Preview
    # @param variant select {{ Ui::CardComponent::VARIANTS.keys }}
    # @param size select {{ Ui::CardComponent::SIZES.keys }}
    def default(variant: "default", size: "md")
      render Ui::CardComponent.new(
        variant: variant.to_sym,
        size: size.to_sym,
        title: "Card Title",
        description: "This is a sample card description that demonstrates the card component."
      )
    end

    # @!group Variants
    def default_card
      render Ui::CardComponent.new(
        title: "Default Card",
        description: "A basic card with default styling."
      )
    end

    def elevated_card
      render Ui::CardComponent.new(
        variant: :elevated,
        title: "Elevated Card",
        description: "A card with enhanced shadow for emphasis."
      )
    end

    def outlined_card
      render Ui::CardComponent.new(
        variant: :outlined,
        title: "Outlined Card",
        description: "A card with a visible border instead of shadow."
      )
    end

    def ghost_card
      render Ui::CardComponent.new(
        variant: :ghost,
        title: "Ghost Card",
        description: "A card with no background or border."
      )
    end

    def interactive_card
      render Ui::CardComponent.new(
        variant: :interactive,
        title: "Interactive Card",
        description: "A card that responds to hover interactions."
      )
    end
    # @!endgroup

    # @!group Sizes
    def small_card
      render Ui::CardComponent.new(
        size: :sm,
        title: "Small Card",
        description: "Compact card with reduced padding."
      )
    end

    def medium_card
      render Ui::CardComponent.new(
        size: :md,
        title: "Medium Card",
        description: "Standard card with default padding."
      )
    end

    def large_card
      render Ui::CardComponent.new(
        size: :lg,
        title: "Large Card",
        description: "Spacious card with increased padding."
      )
    end

    def extra_large_card
      render Ui::CardComponent.new(
        size: :xl,
        title: "Extra Large Card",
        description: "Maximum padding for important content."
      )
    end
    # @!endgroup

    # @!group With Custom Content
    def with_custom_header
      render Ui::CardComponent.new do |card|
        card.with_header do
          content_tag(:div, class: "flex items-center justify-between") do
            concat(content_tag(:h3, "Custom Header", class: "text-lg font-semibold"))
            concat(content_tag(:span, "Badge", class: "px-2 py-1 text-xs bg-primary text-primary-foreground rounded"))
          end
        end
        "This card has a custom header with additional elements."
      end
    end

    def with_footer
      render Ui::CardComponent.new(
        title: "Card with Footer",
        description: "This card includes a footer section."
      ) do |card|
        card.with_footer do
          content_tag(:div, class: "flex justify-end space-x-2") do
            concat(render(Ui::ButtonComponent.new(variant: :ghost, size: :sm) { "Cancel" }))
            concat(render(Ui::ButtonComponent.new(variant: :primary, size: :sm) { "Save" }))
          end
        end
      end
    end

    def with_complex_content
      render Ui::CardComponent.new(
        title: "Financial Summary",
        subtitle: "Monthly Overview"
      ) do
        content_tag(:div, class: "space-y-4") do
          concat(content_tag(:div, class: "grid grid-cols-2 gap-4") do
            concat(content_tag(:div, class: "text-center") do
              concat(content_tag(:div, "$12,345", class: "text-2xl font-bold text-green-600"))
              concat(content_tag(:div, "Income", class: "text-sm text-muted-foreground"))
            end)
            concat(content_tag(:div, class: "text-center") do
              concat(content_tag(:div, "$8,901", class: "text-2xl font-bold text-red-600"))
              concat(content_tag(:div, "Expenses", class: "text-sm text-muted-foreground"))
            end)
          end)
          concat(content_tag(:div, class: "pt-4 border-t") do
            concat(content_tag(:div, "$3,444", class: "text-xl font-semibold"))
            concat(content_tag(:div, "Net Income", class: "text-sm text-muted-foreground"))
          end)
        end
      end
    end
    # @!endgroup

    # @!group As Links
    def clickable_card
      render Ui::CardComponent.new(
        href: "#",
        variant: :interactive,
        title: "Clickable Card",
        description: "This entire card is clickable and will navigate somewhere."
      )
    end

    def external_link_card
      render Ui::CardComponent.new(
        href: "https://example.com",
        target: "_blank",
        variant: :interactive,
        title: "External Link Card",
        description: "This card links to an external website."
      )
    end
    # @!endgroup

    # @!group Theme Examples
    def theme_showcase
      content_tag(:div, class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4") do
        Ui::CardComponent::VARIANTS.keys.each do |variant|
          concat(render(Ui::CardComponent.new(
            variant: variant,
            title: "#{variant.to_s.humanize} Card",
            description: "Example of #{variant} variant styling."
          )))
        end
      end
    end
    # @!endgroup
  end
end
