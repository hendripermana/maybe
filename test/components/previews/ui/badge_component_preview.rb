# frozen_string_literal: true

module Ui
  class BadgeComponentPreview < ViewComponent::Preview
    # @param variant select {{ Ui::BadgeComponent::VARIANTS.keys }}
    # @param size select {{ Ui::BadgeComponent::SIZES.keys }}
    def default(variant: "default", size: "sm")
      render Ui::BadgeComponent.new(
        variant: variant.to_sym,
        size: size.to_sym
      ) do
        "Badge Text"
      end
    end

    # @!group Variants
    def default_badge
      render Ui::BadgeComponent.new(variant: :default) { "Default" }
    end

    def primary_badge
      render Ui::BadgeComponent.new(variant: :primary) { "Primary" }
    end

    def success_badge
      render Ui::BadgeComponent.new(variant: :success) { "Success" }
    end

    def warning_badge
      render Ui::BadgeComponent.new(variant: :warning) { "Warning" }
    end

    def destructive_badge
      render Ui::BadgeComponent.new(variant: :destructive) { "Destructive" }
    end

    def outline_badge
      render Ui::BadgeComponent.new(variant: :outline) { "Outline" }
    end
    # @!endgroup

    # @!group Sizes
    def small_badge
      render Ui::BadgeComponent.new(size: :sm) { "Small" }
    end

    def medium_badge
      render Ui::BadgeComponent.new(size: :md) { "Medium" }
    end

    def large_badge
      render Ui::BadgeComponent.new(size: :lg) { "Large" }
    end
    # @!endgroup

    # @!group Examples
    def status_badges
      content_tag(:div, class: "flex flex-wrap gap-2") do
        concat(render(Ui::BadgeComponent.new(variant: :success) { "Active" }))
        concat(render(Ui::BadgeComponent.new(variant: :warning) { "Pending" }))
        concat(render(Ui::BadgeComponent.new(variant: :destructive) { "Inactive" }))
        concat(render(Ui::BadgeComponent.new(variant: :outline) { "Draft" }))
      end
    end

    def notification_badges
      content_tag(:div, class: "space-y-2") do
        concat(content_tag(:div, class: "flex items-center gap-2") do
          concat(content_tag(:span, "Messages"))
          concat(render(Ui::BadgeComponent.new(variant: :primary, size: :sm) { "3" }))
        end)
        concat(content_tag(:div, class: "flex items-center gap-2") do
          concat(content_tag(:span, "Notifications"))
          concat(render(Ui::BadgeComponent.new(variant: :destructive, size: :sm) { "12" }))
        end)
      end
    end
    # @!endgroup
  end
end