# frozen_string_literal: true

module Ui
  # Navigation item component with consistent styling and active state indicators
  class NavigationItemComponent < ViewComponent::Base
    attr_reader :name, :path, :icon, :icon_custom, :active, :color_classes, :variant

    def initialize(name:, path:, icon:, icon_custom:, active:, color_classes:, variant: "default", **options)
      super(**options)
      @name = name
      @path = path
      @icon = icon
      @icon_custom = icon_custom
      @active = active
      @color_classes = color_classes
      @variant = variant
    end
  end
end
