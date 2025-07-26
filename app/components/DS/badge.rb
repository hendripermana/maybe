# frozen_string_literal: true

# A badge component for displaying status, labels, and tags
# Follows Shadcn-UI badge patterns with our design system
class DS::Badge < DesignSystemComponent
  VARIANTS = {
    default: {
      container_classes: "bg-gray-900 text-white theme-dark:bg-gray-50 theme-dark:text-gray-900"
    },
    secondary: {
      container_classes: "bg-gray-100 text-gray-900 theme-dark:bg-gray-800 theme-dark:text-gray-50"
    },
    destructive: {
      container_classes: "bg-red-500 text-white theme-dark:bg-red-900 theme-dark:text-red-50"
    },
    success: {
      container_classes: "bg-green-500 text-white theme-dark:bg-green-900 theme-dark:text-green-50"
    },
    warning: {
      container_classes: "bg-yellow-500 text-white theme-dark:bg-yellow-900 theme-dark:text-yellow-50"
    },
    outline: {
      container_classes: "border border-primary bg-transparent text-primary"
    }
  }.freeze

  SIZES = {
    sm: {
      container_classes: "px-1.5 py-0.5 text-xs",
      radius_classes: "rounded-md"
    },
    md: {
      container_classes: "px-2 py-1 text-xs",
      radius_classes: "rounded-md"
    },
    lg: {
      container_classes: "px-2.5 py-1 text-sm",
      radius_classes: "rounded-lg"
    }
  }.freeze

  attr_reader :variant, :size, :text, :icon, :opts

  def initialize(variant: :default, size: :md, text: nil, icon: nil, **opts)
    @variant = variant.to_sym
    @size = size.to_sym
    @text = text
    @icon = icon
    @opts = opts
  end

  private

  def container_classes
    extra_classes = opts.delete(:class)
    
    class_names(
      "inline-flex items-center gap-1 font-medium whitespace-nowrap",
      variant_classes,
      size_classes,
      radius_classes,
      extra_classes
    )
  end

  def variant_classes
    VARIANTS.dig(variant, :container_classes)
  end

  def size_classes
    SIZES.dig(size, :container_classes)
  end

  def radius_classes
    SIZES.dig(size, :radius_classes)
  end

  def icon_size
    case size
    when :sm then :xs
    when :md then :sm
    when :lg then :sm
    else :sm
    end
  end

  def icon_color
    case variant
    when :outline then :default
    else :white
    end
  end

  def html_attributes
    merged_opts = opts.dup
    merged_opts.delete(:class) # Already handled in container_classes
    merged_opts
  end
end