class ButtonishComponent < ViewComponent::Base
  VARIANTS = {
    primary: {
      container_classes: "text-white bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 focus:ring-4 focus:ring-blue-200 shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-300 disabled:from-gray-400 disabled:to-gray-500 disabled:transform-none disabled:shadow-none",
      icon_classes: "text-white"
    },
    secondary: {
      container_classes: "text-gray-700 bg-white border-2 border-gray-200 hover:border-blue-300 hover:bg-blue-50 focus:ring-4 focus:ring-blue-100 shadow-sm hover:shadow-md transition-all duration-200 disabled:bg-gray-100 disabled:text-gray-400 disabled:border-gray-200",
      icon_classes: "text-gray-600"
    },
    destructive: {
      container_classes: "text-white bg-gradient-to-r from-red-500 to-red-600 hover:from-red-600 hover:to-red-700 focus:ring-4 focus:ring-red-200 shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-300 disabled:from-gray-400 disabled:to-gray-500 disabled:transform-none",
      icon_classes: "text-white"
    },
    outline: {
      container_classes: "text-gray-700 border-2 border-gray-200 bg-white hover:border-blue-300 hover:bg-blue-50 focus:ring-4 focus:ring-blue-100 shadow-sm hover:shadow-md transition-all duration-200",
      icon_classes: "text-gray-600"
    },
    outline_destructive: {
      container_classes: "text-red-600 border-2 border-red-200 bg-white hover:border-red-300 hover:bg-red-50 focus:ring-4 focus:ring-red-100 shadow-sm hover:shadow-md transition-all duration-200",
      icon_classes: "text-red-600"
    },
    ghost: {
      container_classes: "text-gray-700 bg-transparent hover:bg-gray-100 focus:ring-4 focus:ring-gray-100 rounded-lg transition-all duration-200",
      icon_classes: "text-gray-600"
    },
    icon: {
      container_classes: "text-gray-600 hover:text-gray-800 hover:bg-gray-100 focus:ring-4 focus:ring-gray-100 rounded-lg transition-all duration-200",
      icon_classes: "text-gray-600"
    },
    icon_inverse: {
      container_classes: "text-white bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 focus:ring-4 focus:ring-blue-200 shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-300",
      icon_classes: "text-white"
    }
  }.freeze

  SIZES = {
    sm: {
      container_classes: "px-2 py-1",
      icon_container_classes: "inline-flex items-center justify-center w-8 h-8",
      radius_classes: "rounded-md",
      text_classes: "text-sm"
    },
    md: {
      container_classes: "px-3 py-2",
      icon_container_classes: "inline-flex items-center justify-center w-9 h-9",
      radius_classes: "rounded-lg",
      text_classes: "text-sm"
    },
    lg: {
      container_classes: "px-4 py-3",
      icon_container_classes: "inline-flex items-center justify-center w-10 h-10",
      radius_classes: "rounded-xl",
      text_classes: "text-base"
    }
  }.freeze

  attr_reader :variant, :size, :href, :icon, :icon_position, :text, :full_width, :extra_classes, :frame, :opts

  def initialize(variant: :primary, size: :md, href: nil, text: nil, icon: nil, icon_position: :left, full_width: false, frame: nil, **opts)
    @variant = variant.to_s.underscore.to_sym
    @size = size.to_sym
    @href = href
    @icon = icon
    @icon_position = icon_position.to_sym
    @text = text
    @full_width = full_width
    @extra_classes = opts.delete(:class)
    @frame = frame
    @opts = opts
  end

  def call
    raise NotImplementedError, "ButtonishComponent is an abstract class and cannot be instantiated directly."
  end

  def container_classes(override_classes = nil)
    class_names(
      "font-medium whitespace-nowrap",
      merged_base_classes,
      full_width ? "w-full justify-center" : nil,
      container_size_classes,
      size_data.dig(:text_classes),
      variant_data.dig(:container_classes)
    )
  end

  def container_size_classes
    icon_only? ? size_data.dig(:icon_container_classes) : size_data.dig(:container_classes)
  end

  def icon_color
    # Map variant to icon color for the icon helper
    case variant
    when :primary, :icon_inverse
      :white
    when :destructive, :outline_destructive
      :destructive
    else
      :default
    end
  end

  def icon_classes
    class_names(
      variant_data.dig(:icon_classes)
    )
  end

  def icon_only?
    variant.in?([ :icon, :icon_inverse ])
  end

  private
    def variant_data
      self.class::VARIANTS.dig(variant)
    end

    def size_data
      self.class::SIZES.dig(size)
    end

    # Make sure that user can override common classes like `hidden`
    def merged_base_classes
      base_display_classes = "inline-flex items-center gap-1"
      base_radius_classes = size_data.dig(:radius_classes)

      extra_classes_list = (extra_classes || "").split

      has_display_override = extra_classes_list.any? { |c| permitted_display_override_classes.include?(c) }
      has_radius_override = extra_classes_list.any? { |c| permitted_radius_override_classes.include?(c) }

      base_classes = []

      unless has_display_override
        base_classes << base_display_classes
      end

      unless has_radius_override
        base_classes << base_radius_classes
      end

      class_names(
        base_classes,
        extra_classes
      )
    end

    def permitted_radius_override_classes
      [ "rounded-full" ]
    end

    def permitted_display_override_classes
      [ "hidden", "flex" ]
    end
end
