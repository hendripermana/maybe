# frozen_string_literal: true

module Ui
  # Separator component for visually dividing content
  # Follows Shadcn design principles with theme support
  class SeparatorComponent < BaseComponent
    ORIENTATIONS = {
      horizontal: "w-full h-px",
      vertical: "h-full w-px"
    }.freeze

    VARIANTS = {
      default: "bg-gray-200 [data-theme=dark]:bg-gray-700",
      primary: "bg-blue-200 [data-theme=dark]:bg-blue-700",
      success: "bg-green-200 [data-theme=dark]:bg-green-700",
      warning: "bg-yellow-200 [data-theme=dark]:bg-yellow-700",
      destructive: "bg-red-200 [data-theme=dark]:bg-red-700"
    }.freeze

    def initialize(orientation: :horizontal, variant: :default, decorative: true, **options)
      super(variant: variant, size: nil, **options)
      @orientation = orientation.to_sym
      @decorative = decorative
    end

    private

    attr_reader :orientation, :decorative

    def container_classes
      build_classes(
        "shrink-0",
        ORIENTATIONS[orientation],
        VARIANTS[variant]
      )
    end

    def aria_attributes
      decorative ? { "aria-hidden": "true" } : {}
    end
  end
end