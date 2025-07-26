# frozen_string_literal: true

# A flexible card component that follows Shadcn-UI patterns
# Provides variants for different visual styles and supports compound composition
class DS::Card < DesignSystemComponent
  VARIANTS = {
    default: {
      container_classes: "bg-container border border-primary shadow-sm"
    },
    outline: {
      container_classes: "bg-transparent border border-primary"
    },
    ghost: {
      container_classes: "bg-transparent border-0"
    },
    filled: {
      container_classes: "bg-surface border-0"
    }
  }.freeze

  SIZES = {
    sm: {
      container_classes: "p-3",
      radius_classes: "rounded-md"
    },
    md: {
      container_classes: "p-4",
      radius_classes: "rounded-lg"
    },
    lg: {
      container_classes: "p-6",
      radius_classes: "rounded-xl"
    }
  }.freeze

  # Compound component slots (Shadcn-UI style)
  renders_one :header
  renders_one :body
  renders_one :footer

  def header(title: nil, subtitle: nil, **opts, &block)
    content_tag(:header, class: "space-y-1.5 pb-3", **opts) do
      title_element = content_tag(:h3, title, class: "text-lg font-semibold text-primary") if title
      subtitle_element = content_tag(:p, subtitle, class: "text-sm text-secondary") if subtitle
      block_content = capture(&block) if block
      
      safe_join([title_element, subtitle_element, block_content].compact)
    end
  end

  def body(css_class: nil, **opts, &block)
    content_tag(:div, class: class_names("text-sm text-primary", css_class), **opts, &block)
  end

  def footer(css_class: nil, **opts, &block)
    content_tag(:footer, class: class_names("pt-3 border-t border-primary", css_class), **opts, &block)
  end

  attr_reader :variant, :size, :opts

  def initialize(variant: :default, size: :md, **opts)
    @variant = variant.to_sym
    @size = size.to_sym
    @opts = opts
  end

  private

  def container_classes
    extra_classes = opts.delete(:class)
    
    class_names(
      "overflow-hidden", # Base card behavior
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

  def html_attributes
    merged_opts = opts.dup
    merged_opts.delete(:class) # Already handled in container_classes
    merged_opts
  end
end