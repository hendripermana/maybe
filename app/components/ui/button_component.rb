# frozen_string_literal: true

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
