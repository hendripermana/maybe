# frozen_string_literal: true

class Ui::BadgeComponent < ViewComponent::Base
  attr_reader :variant, :size

  VARIANTS = {
    default: "bg-gray-100 text-gray-800 border-gray-200",
    primary: "bg-blue-100 text-blue-800 border-blue-200",
    success: "bg-green-100 text-green-800 border-green-200", 
    warning: "bg-yellow-100 text-yellow-800 border-yellow-200",
    destructive: "bg-red-100 text-red-800 border-red-200",
    outline: "bg-transparent text-gray-700 border-gray-300"
  }.freeze

  SIZES = {
    sm: "px-2 py-0.5 text-xs",
    md: "px-2.5 py-1 text-sm",
    lg: "px-3 py-1.5 text-base"
  }.freeze

  def initialize(variant: :default, size: :sm, **html_options)
    @variant = variant
    @size = size
    @html_options = html_options
  end

  private

  def css_classes
    classes = [
      "inline-flex items-center font-medium border rounded-full transition-all duration-200",
      VARIANTS[variant],
      SIZES[size]
    ]
    
    classes << @html_options[:class] if @html_options[:class]
    classes.compact.join(" ")
  end

  def html_options
    @html_options.except(:class).merge(class: css_classes)
  end
end
