# frozen_string_literal: true

# ShadCN-inspired Card component that extends Maybe's design system
class Ui::CardComponent < ViewComponent::Base
  attr_reader :variant, :size, :hover_effect, :title, :subtitle, :description, :href, :target, :frame

  VARIANTS = {
    default: "bg-container shadow-border-xs rounded-xl",
    elevated: "bg-container shadow-border-md hover:shadow-border-lg transition-all duration-200 rounded-xl",
    outlined: "bg-container border border-secondary hover:border-primary transition-all duration-200 rounded-xl",
    ghost: "bg-transparent border-0 shadow-none rounded-xl",
    gradient: "bg-container shadow-border-xs rounded-xl",
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

  private

  def css_classes
    classes = [
      VARIANTS[variant],
      SIZES[size]
    ]
    
    classes << @html_options[:class] if @html_options[:class]
    classes.compact.join(" ")
  end

  def wrapper_tag
    href ? :a : :div
  end

  def wrapper_options
    base_options = {
      class: css_classes
    }.merge(@html_options.except(:class))

    if href
      base_options.merge!(
        href: href,
        target: target,
        data: { turbo_frame: frame }.compact.merge(@html_options[:data] || {})
      )
    else
      base_options[:data] = @html_options[:data] if @html_options[:data]
    end

    base_options
  end

  def has_header?
    title.present? || subtitle.present? || content_for?(:header)
  end

  def has_content?
    description.present? || content_for?(:content)
  end

  def has_footer?
    content_for?(:footer)
  end

  def title_classes
    "text-lg font-semibold text-primary leading-tight"
  end

  def subtitle_classes
    "text-sm font-medium text-secondary"
  end

  def description_classes
    "text-sm text-subdued leading-relaxed"
  end
end
