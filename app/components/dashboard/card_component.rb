# frozen_string_literal: true

# Modern dashboard card component with ShadCN design principles
class Dashboard::CardComponent < ViewComponent::Base
  attr_reader :title, :value, :description, :trend, :icon_name, :variant, :loading

  VARIANTS = {
    default: "card-modern",
    elevated: "card-modern shadow-floating hover:shadow-modal",
    minimal: "bg-card text-card-foreground border-0 shadow-none",
    accent: "card-modern bg-gradient-to-br from-blue-500/10 to-purple-500/10 border-blue-200 [data-theme=dark]:border-blue-800",
    success: "card-modern bg-gradient-to-br from-green-500/10 to-emerald-500/10 border-green-200 [data-theme=dark]:border-green-800",
    warning: "card-modern bg-gradient-to-br from-yellow-500/10 to-orange-500/10 border-yellow-200 [data-theme=dark]:border-yellow-800",
    destructive: "card-modern bg-gradient-to-br from-red-500/10 to-pink-500/10 border-red-200 [data-theme=dark]:border-red-800"
  }.freeze

  def initialize(
    title:,
    value: nil,
    description: nil,
    trend: nil,
    icon_name: nil,
    variant: :default,
    loading: false,
    **html_options
  )
    @title = title
    @value = value
    @description = description
    @trend = trend
    @icon_name = icon_name
    @variant = variant
    @loading = loading
    @html_options = html_options
  end

  private

    def css_classes
      classes = [
        "p-6 space-y-4",
        VARIANTS[variant]
      ]

      classes << @html_options[:class] if @html_options[:class]
      classes.compact.join(" ")
    end

    def html_options
      @html_options.except(:class).merge(class: css_classes)
    end

    def icon_variant_class
      case @variant
      when :success
        "icon-bg-success"
      when :warning
        "icon-bg-warning"
      when :destructive
        "icon-bg-destructive"
      when :accent
        "icon-bg-primary"
      else
        "icon-bg-muted"
      end
    end

    def trend_variant_class
      return "" unless trend

      if trend[:direction] == :up && trend[:positive] == true
        "text-success"
      elsif trend[:direction] == :down && trend[:positive] == true
        "text-success"
      elsif trend[:direction] == :up && trend[:positive] == false
        "text-destructive"
      elsif trend[:direction] == :down && trend[:positive] == false
        "text-destructive"
      else
        "text-muted-foreground"
      end
    end

    def trend_icon
      return "" unless trend

      case trend[:direction]
      when :up
        "trending-up"
      when :down
        "trending-down"
      else
        "minus"
      end
    end
end
