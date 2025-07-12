# frozen_string_literal: true

# ShadCN-inspired Card component that extends Maybe's design system
class Ui::CardComponent < ViewComponent::Base
  attr_reader :variant, :size, :hover_effect, :title, :subtitle, :description, :href, :target, :frame

  VARIANTS = {
    default: "bg-container shadow-border-xs rounded-xl",
    elevated: "bg-container shadow-border-md hover:shadow-border-lg transition-all duration-200 rounded-xl",
    outlined: "bg-container border border-secondary hover:border-primary transition-all duration-200 rounded-xl",
    ghost: "bg-transparent border-0 shadow-none rounded-xl",
    gradient: "bg-gradient-to-br from-container to-container-inset shadow-border-xs rounded-xl",
    interactive: "bg-container shadow-border-xs hover:shadow-border-md hover:bg-container-hover cursor-pointer transition-all duration-200 rounded-xl"
  }.freeze

  SIZES = {
    sm: "p-4",
    md: "p-6", 
    lg: "p-8"
  }.freeze

  def initialize(
    variant: :default, 
    size: :md, 
    hover_effect: true, 
    title: nil,
    subtitle: nil,
    description: nil,
    href: nil,
    target: nil,
    frame: nil,
    **html_options
  )
    @variant = variant
    @size = size
    @hover_effect = hover_effect
    @title = title
    @subtitle = subtitle
    @description = description
    @href = href
    @target = target
    @frame = frame
    @html_options = html_options
  end
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
