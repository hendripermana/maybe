# frozen_string_literal: true

module Ui
  # Alert component for displaying messages with different variants
  # Follows Shadcn design principles with theme support
  class AlertComponent < BaseComponent
    VARIANTS = {
      default: "bg-gray-50 text-gray-800 border-gray-200 [data-theme=dark]:bg-gray-900/20 [data-theme=dark]:text-gray-300 [data-theme=dark]:border-gray-800",
      info: "bg-blue-50 text-blue-700 border-blue-200 [data-theme=dark]:bg-blue-900/20 [data-theme=dark]:text-blue-400 [data-theme=dark]:border-blue-800",
      success: "bg-green-50 text-green-700 border-green-200 [data-theme=dark]:bg-green-900/20 [data-theme=dark]:text-green-400 [data-theme=dark]:border-green-800",
      warning: "bg-yellow-50 text-yellow-700 border-yellow-200 [data-theme=dark]:bg-yellow-900/20 [data-theme=dark]:text-yellow-400 [data-theme=dark]:border-yellow-800",
      destructive: "bg-red-50 text-red-700 border-red-200 [data-theme=dark]:bg-red-900/20 [data-theme=dark]:text-red-400 [data-theme=dark]:border-red-800"
    }.freeze

    SIZES = {
      sm: "p-3 text-sm",
      md: "p-4 text-base",
      lg: "p-5 text-lg"
    }.freeze

    def initialize(title: nil, variant: :default, size: :md, dismissible: false, **options)
      super(variant: variant, size: size, **options)
      @title = title
      @dismissible = dismissible
    end

    private

      attr_reader :title, :dismissible

      def container_classes
        build_classes(
          "flex items-start gap-3 rounded-lg border",
          VARIANTS[variant],
          SIZES[size]
        )
      end

      def icon_name
        case variant
        when :info then "info"
        when :success then "check-circle"
        when :warning then "alert-triangle"
        when :destructive then "x-circle"
        else "bell"
        end
      end

      def icon_color
        case variant
        when :info then "blue-600"
        when :success then "success"
        when :warning then "warning"
        when :destructive then "destructive"
        else "gray-600"
        end
      end
  end
end
