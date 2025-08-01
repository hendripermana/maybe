# frozen_string_literal: true

module Ui
  # Skeleton component for loading states
  # Follows Shadcn design principles with theme support
  class SkeletonComponent < BaseComponent
    VARIANTS = {
      default: "bg-gray-200 [data-theme=dark]:bg-gray-700",
      primary: "bg-blue-100 [data-theme=dark]:bg-blue-900/50",
      success: "bg-green-100 [data-theme=dark]:bg-green-900/50",
      warning: "bg-yellow-100 [data-theme=dark]:bg-yellow-900/50",
      destructive: "bg-red-100 [data-theme=dark]:bg-red-900/50"
    }.freeze

    def initialize(width: nil, height: nil, variant: :default, rounded: true, animate: true, **options)
      super(variant: variant, size: nil, **options)
      @width = width
      @height = height
      @rounded = rounded
      @animate = animate
    end

    private

      attr_reader :width, :height, :rounded, :animate

      def container_classes
        build_classes(
          VARIANTS[variant],
          rounded ? "rounded-md" : "",
          animate ? "animate-pulse" : "",
          "inline-block"
        )
      end

      def container_styles
        styles = {}
        styles[:width] = width if width
        styles[:height] = height if height

        styles.map { |k, v| "#{k}: #{v}" }.join("; ")
      end
  end
end
