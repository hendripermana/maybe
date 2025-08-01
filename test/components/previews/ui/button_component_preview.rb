# frozen_string_literal: true

module Ui
  class ButtonComponentPreview < ViewComponent::Preview
    # @param variant select {{ Ui::ButtonComponent::VARIANTS.keys }}
    # @param size select {{ Ui::ButtonComponent::SIZES.keys }}
    # @param disabled toggle
    # @param loading toggle
    # @param full_width toggle
    def default(variant: "primary", size: "md", disabled: false, loading: false, full_width: false)
      render Ui::ButtonComponent.new(
        variant: variant.to_sym,
        size: size.to_sym,
        disabled: disabled,
        loading: loading,
        full_width: full_width
      ) do
        "Click me"
      end
    end

    # @!group Variants
    def primary
      render Ui::ButtonComponent.new(variant: :primary) { "Primary Button" }
    end

    def secondary
      render Ui::ButtonComponent.new(variant: :secondary) { "Secondary Button" }
    end

    def destructive
      render Ui::ButtonComponent.new(variant: :destructive) { "Destructive Button" }
    end

    def outline
      render Ui::ButtonComponent.new(variant: :outline) { "Outline Button" }
    end

    def ghost
      render Ui::ButtonComponent.new(variant: :ghost) { "Ghost Button" }
    end

    def link
      render Ui::ButtonComponent.new(variant: :link) { "Link Button" }
    end
    # @!endgroup

    # @!group Sizes
    def small
      render Ui::ButtonComponent.new(size: :sm) { "Small Button" }
    end

    def medium
      render Ui::ButtonComponent.new(size: :md) { "Medium Button" }
    end

    def large
      render Ui::ButtonComponent.new(size: :lg) { "Large Button" }
    end

    def extra_large
      render Ui::ButtonComponent.new(size: :xl) { "Extra Large Button" }
    end
    # @!endgroup

    # @!group States
    def disabled_state
      render Ui::ButtonComponent.new(disabled: true) { "Disabled Button" }
    end

    def loading_state
      render Ui::ButtonComponent.new(loading: true) { "Loading Button" }
    end

    def full_width_button
      render Ui::ButtonComponent.new(full_width: true) { "Full Width Button" }
    end
    # @!endgroup

    # @!group With Icons
    def with_left_icon
      render Ui::ButtonComponent.new(icon: "plus", icon_position: :left) { "Add Item" }
    end

    def with_right_icon
      render Ui::ButtonComponent.new(icon: "arrow-right", icon_position: :right) { "Continue" }
    end
    # @!endgroup

    # @!group As Links
    def as_link
      render Ui::ButtonComponent.new(href: "#", variant: :primary) { "Link Button" }
    end

    def external_link
      render Ui::ButtonComponent.new(href: "https://example.com", target: "_blank") { "External Link" }
    end
    # @!endgroup

    # @!group Theme Examples
    def theme_showcase
      content_tag(:div, class: "space-y-4") do
        concat(content_tag(:div, class: "space-x-2") do
          concat(render(Ui::ButtonComponent.new(variant: :primary) { "Primary" }))
          concat(render(Ui::ButtonComponent.new(variant: :secondary) { "Secondary" }))
          concat(render(Ui::ButtonComponent.new(variant: :destructive) { "Destructive" }))
          concat(render(Ui::ButtonComponent.new(variant: :outline) { "Outline" }))
          concat(render(Ui::ButtonComponent.new(variant: :ghost) { "Ghost" }))
        end)
        concat(content_tag(:p, "Switch themes to see consistent styling across light and dark modes.", class: "text-sm text-muted-foreground"))
      end
    end
    # @!endgroup
  end
end
