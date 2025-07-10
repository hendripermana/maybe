# frozen_string_literal: true

class Ui::CardComponent < ViewComponent::Base
  attr_reader :variant, :size, :hover_effect

  VARIANTS = {
    default: "bg-white border border-gray-200 shadow-sm",
    elevated: "bg-white border border-gray-200 shadow-lg",
    outlined: "bg-white border-2 border-gray-200",
    ghost: "bg-transparent border-0 shadow-none"
  }.freeze

  SIZES = {
    sm: "p-4",
    md: "p-6", 
    lg: "p-8"
  }.freeze

  def initialize(variant: :default, size: :md, hover_effect: true, **html_options)
    @variant = variant
    @size = size
    @hover_effect = hover_effect
    @html_options = html_options
  end

  private

  def css_classes
    classes = [
      "rounded-xl transition-all duration-300",
      VARIANTS[variant],
      SIZES[size]
    ]
    
    classes << "hover:shadow-xl hover:scale-[1.02]" if hover_effect
    classes << @html_options[:class] if @html_options[:class]
    
    classes.compact.join(" ")
  end

  def html_options
    @html_options.except(:class).merge(class: css_classes)
  end
end
