# frozen_string_literal: true

<<<<<<< HEAD
class Ui::ButtonComponent < ViewComponent::Base
  attr_reader :variant, :size, :loading, :disabled

  VARIANTS = {
    default: "bg-gray-900 text-white hover:bg-gray-800 focus:ring-gray-900",
    destructive: "bg-red-500 text-white hover:bg-red-600 focus:ring-red-500",
    outline: "border border-gray-300 bg-white text-gray-700 hover:bg-gray-50 hover:border-gray-400 focus:ring-gray-500",
    secondary: "bg-gray-100 text-gray-900 hover:bg-gray-200 focus:ring-gray-500",
    ghost: "text-gray-700 hover:bg-gray-100 focus:ring-gray-500",
    link: "text-blue-600 hover:text-blue-800 underline-offset-4 hover:underline focus:ring-blue-500"
  }.freeze

  SIZES = {
    sm: "h-8 px-3 text-xs",
    md: "h-10 px-4 py-2 text-sm", 
    lg: "h-12 px-8 text-base",
    icon: "h-10 w-10"
  }.freeze

  def initialize(variant: :default, size: :md, loading: false, disabled: false, **html_options)
    @variant = variant
    @size = size
    @loading = loading
    @disabled = disabled || loading
    @html_options = html_options
  end

  private

  def css_classes
    classes = [
      "inline-flex items-center justify-center rounded-lg font-medium transition-all duration-200",
      "focus:outline-none focus:ring-2 focus:ring-offset-2",
      VARIANTS[variant],
      SIZES[size]
    ]
    
    if disabled
      classes << "opacity-50 cursor-not-allowed"
    else
      classes << "transform hover:scale-105 active:scale-95"
    end
    
    classes << @html_options[:class] if @html_options[:class]
    classes.compact.join(" ")
  end

  def html_options
    options = @html_options.except(:class).merge(
      class: css_classes,
      disabled: disabled
    )
    
    options[:type] ||= "button" unless @html_options[:href]
    options
  end
end
=======
module Ui
  # Modern Shadcn-inspired Button component with theme support
  # Uses CSS variables for consistent theming across light and dark modes
  class ButtonComponent < BaseComponent
    VARIANTS = {
      default: "btn-modern-secondary",
      primary: "btn-modern-primary", 
      secondary: "btn-modern-secondary",
      destructive: "btn-modern-destructive",
      outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
      ghost: "btn-modern-ghost",
      link: "text-primary underline-offset-4 hover:underline"
    }.freeze

    SIZES = {
      sm: "h-9 rounded-md px-3 text-xs",
      md: "h-10 px-4 py-2 rounded-md", 
      lg: "h-11 rounded-md px-8",
      xl: "h-12 rounded-lg px-10 text-base"
    }.freeze

    attr_reader :href, :disabled, :loading, :icon, :icon_position, :full_width, :type

    def initialize(
      variant: :default,
      size: :md,
      href: nil,
      disabled: false,
      loading: false,
      icon: nil,
      icon_position: :left,
      full_width: false,
      type: "button",
      **options
    )
      super(variant: variant, size: size, **options)
      @href = href
      @disabled = disabled || loading
      @loading = loading
      @icon = icon
      @icon_position = icon_position.to_sym
      @full_width = full_width
      @type = type
    end

    def call
      if @href.present?
        link_to(@href, **link_attributes) { button_content }
      else
        content_tag(:button, **button_attributes) { button_content }
      end
    end

    private

    def button_content
      if @variant == :link
        content
      else
        content_tag(:span, class: "inline-flex items-center gap-2") do
          concat(loading_spinner) if @loading
          concat(left_icon) if @icon && @icon_position == :left && !@loading
          concat(content) if content.present?
          concat(right_icon) if @icon && @icon_position == :right && !@loading
        end
      end
    end

    def button_attributes
      {
        type: @type,
        disabled: @disabled,
        class: button_classes,
        data: build_data_attributes,
        **build_options.except(:class, :data)
      }
    end

    def link_attributes
      {
        class: button_classes,
        data: build_data_attributes,
        **build_options.except(:class, :data)
      }
    end

    def button_classes
      base_classes = [
        "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium",
        "ring-offset-background transition-colors",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        "disabled:pointer-events-none disabled:opacity-50"
      ]

      base_classes << "w-full" if @full_width
      
      build_classes(
        *base_classes,
        variant_classes,
        size_classes
      )
    end

    def variant_classes
      VARIANTS[@variant] || VARIANTS[:default]
    end

    def size_classes
      SIZES[@size] || SIZES[:md]
    end

    def loading_spinner
      content_tag(:svg, 
        class: "animate-spin h-4 w-4", 
        xmlns: "http://www.w3.org/2000/svg", 
        fill: "none", 
        viewBox: "0 0 24 24"
      ) do
        concat(content_tag(:circle, nil, 
          class: "opacity-25", 
          cx: "12", 
          cy: "12", 
          r: "10", 
          stroke: "currentColor", 
          "stroke-width": "4"
        ))
        concat(content_tag(:path, nil, 
          class: "opacity-75", 
          fill: "currentColor", 
          d: "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
        ))
      end
    end

    def left_icon
      return unless @icon
      
      if defined?(helpers) && helpers.respond_to?(:icon)
        helpers.icon(@icon, size: icon_size, class: "shrink-0")
      else
        content_tag(:span, @icon, class: "shrink-0")
      end
    end

    def right_icon
      return unless @icon
      
      if defined?(helpers) && helpers.respond_to?(:icon)
        helpers.icon(@icon, size: icon_size, class: "shrink-0")
      else
        content_tag(:span, @icon, class: "shrink-0")
      end
    end

    def icon_size
      case @size
      when :sm then 14
      when :md then 16
      when :lg then 18
      when :xl then 20
      else 16
      end
    end
  end
end
>>>>>>> feature/modernation-design
