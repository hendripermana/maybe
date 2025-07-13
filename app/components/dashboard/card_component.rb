# frozen_string_literal: true

# Modern dashboard card component with ShadCN design principles
class Dashboard::CardComponent < ViewComponent::Base
  attr_reader :title, :value, :description, :trend, :icon_name, :variant, :loading

  VARIANTS = {
    default: "bg-card text-card-foreground border shadow-sm",
    elevated: "bg-card text-card-foreground border shadow-md hover:shadow-lg transition-all duration-300",
    minimal: "bg-card text-card-foreground border-0 shadow-none",
    accent: "bg-gradient-to-br from-blue-500/10 to-purple-500/10 border border-blue-200 dark:border-blue-800",
    success: "bg-gradient-to-br from-green-500/10 to-emerald-500/10 border border-green-200 dark:border-green-800",
    warning: "bg-gradient-to-br from-yellow-500/10 to-orange-500/10 border border-yellow-200 dark:border-yellow-800",
    destructive: "bg-gradient-to-br from-red-500/10 to-pink-500/10 border border-red-200 dark:border-red-800"
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
        "rounded-xl p-6 space-y-4 transition-all duration-300",
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
        "text-green-600 bg-green-100 dark:bg-green-900/30 dark:text-green-400"
      when :warning
        "text-yellow-600 bg-yellow-100 dark:bg-yellow-900/30 dark:text-yellow-400"
      when :destructive
        "text-red-600 bg-red-100 dark:bg-red-900/30 dark:text-red-400"
      when :accent
        "text-blue-600 bg-blue-100 dark:bg-blue-900/30 dark:text-blue-400"
      else
        "text-gray-600 bg-gray-100 dark:bg-gray-800 dark:text-gray-300"
      end
    end

    def trend_variant_class
      return "" unless trend

      if trend[:direction] == :up && trend[:positive] == true
        "text-green-600 dark:text-green-400"
      elsif trend[:direction] == :down && trend[:positive] == true
        "text-green-600 dark:text-green-400"
      elsif trend[:direction] == :up && trend[:positive] == false
        "text-red-600 dark:text-red-400"
      elsif trend[:direction] == :down && trend[:positive] == false
        "text-red-600 dark:text-red-400"
      else
        "text-gray-500 dark:text-gray-400"
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
