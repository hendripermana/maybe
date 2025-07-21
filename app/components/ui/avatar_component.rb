# frozen_string_literal: true

module Ui
  # Avatar component for displaying user or entity images
  # Follows Shadcn design principles with theme support
  class AvatarComponent < BaseComponent
    SIZES = {
      xs: "w-6 h-6 text-xs",
      sm: "w-8 h-8 text-sm",
      md: "w-10 h-10 text-base",
      lg: "w-12 h-12 text-lg",
      xl: "w-16 h-16 text-xl"
    }.freeze

    VARIANTS = {
      default: "bg-gray-200 text-gray-700 [data-theme=dark]:bg-gray-700 [data-theme=dark]:text-gray-200",
      primary: "bg-blue-100 text-blue-700 [data-theme=dark]:bg-blue-900 [data-theme=dark]:text-blue-200",
      success: "bg-green-100 text-green-700 [data-theme=dark]:bg-green-900 [data-theme=dark]:text-green-200",
      warning: "bg-yellow-100 text-yellow-700 [data-theme=dark]:bg-yellow-900 [data-theme=dark]:text-yellow-200",
      destructive: "bg-red-100 text-red-700 [data-theme=dark]:bg-red-900 [data-theme=dark]:text-red-200"
    }.freeze

    def initialize(src: nil, alt: "", initials: nil, variant: :default, size: :md, **options)
      super(variant: variant, size: size, **options)
      @src = src
      @alt = alt
      @initials = initials || generate_initials(alt)
    end

    private

    attr_reader :src, :alt, :initials

    def container_classes
      build_classes(
        "inline-flex items-center justify-center rounded-full overflow-hidden",
        SIZES[size],
        src.present? ? "" : VARIANTS[variant]
      )
    end

    def generate_initials(name)
      return "" if name.blank?
      
      name.split(/\s+/)
          .first(2)
          .map { |n| n[0] }
          .join("")
          .upcase
    end
  end
end