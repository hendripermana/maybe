# frozen_string_literal: true

module Ui
  # Tooltip component for displaying additional information on hover
  # Follows Shadcn design principles with theme support
  class TooltipComponent < BaseComponent
    VARIANTS = {
      default: "bg-gray-900 text-white [data-theme=dark]:bg-gray-100 [data-theme=dark]:text-gray-900",
      primary: "bg-blue-600 text-white",
      success: "bg-green-600 text-white",
      warning: "bg-yellow-600 text-white",
      destructive: "bg-red-600 text-white"
    }.freeze

    POSITIONS = {
      top: "bottom-full mb-2",
      bottom: "top-full mt-2",
      left: "right-full mr-2",
      right: "left-full ml-2"
    }.freeze

    def initialize(text:, position: :top, variant: :default, delay_show: 300, delay_hide: 100, **options)
      super(variant: variant, size: nil, **options)
      @text = text
      @position = position.to_sym
      @delay_show = delay_show
      @delay_hide = delay_hide
    end

    private

    attr_reader :text, :position, :delay_show, :delay_hide

    def container_classes
      build_classes(
        "relative inline-block"
      )
    end

    def tooltip_classes
      build_classes(
        "absolute z-50 px-2 py-1 text-xs rounded shadow-md whitespace-nowrap opacity-0 pointer-events-none transition-opacity",
        VARIANTS[variant],
        POSITIONS[position]
      )
    end

    def data_attributes
      {
        controller: "ui--tooltip",
        "ui--tooltip-delay-show-value": delay_show,
        "ui--tooltip-delay-hide-value": delay_hide
      }
    end
  end
end