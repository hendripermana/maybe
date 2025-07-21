# frozen_string_literal: true

module Ui
  # BalanceDisplay component for displaying financial balances
  # Follows Shadcn design principles with theme support
  class BalanceDisplayComponent < BaseComponent
    VARIANTS = {
      default: "text-gray-900 [data-theme=dark]:text-gray-100",
      primary: "text-blue-600 [data-theme=dark]:text-blue-400",
      success: "text-green-600 [data-theme=dark]:text-green-400",
      warning: "text-yellow-600 [data-theme=dark]:text-yellow-400",
      destructive: "text-red-600 [data-theme=dark]:text-red-400"
    }.freeze

    SIZES = {
      xs: "text-xs",
      sm: "text-sm",
      md: "text-base",
      lg: "text-lg",
      xl: "text-xl",
      "2xl": "text-2xl",
      "3xl": "text-3xl"
    }.freeze

    def initialize(amount:, currency: nil, show_sign: false, show_indicator: false, variant: :default, size: :md, **options)
      super(variant: variant, size: size, **options)
      @amount = amount
      @currency = currency || Current.currency
      @show_sign = show_sign
      @show_indicator = show_indicator
    end

    private

    attr_reader :amount, :currency, :show_sign, :show_indicator

    def container_classes
      build_classes(
        "font-medium",
        SIZES[size],
        amount_color_class,
        options[:class]
      )
    end

    def amount_color_class
      return VARIANTS[variant] unless variant == :default && amount.to_f != 0

      if amount.to_f.negative?
        "text-red-600 [data-theme=dark]:text-red-400"
      else
        "text-green-600 [data-theme=dark]:text-green-400"
      end
    end

    def formatted_amount
      helpers.format_currency(amount, currency, show_sign: show_sign)
    end

    def indicator_icon
      if amount.to_f.negative?
        "arrow-down"
      elsif amount.to_f.positive?
        "arrow-up"
      else
        "minus"
      end
    end

    def indicator_color
      if amount.to_f.negative?
        "destructive"
      elsif amount.to_f.positive?
        "success"
      else
        "gray-400"
      end
    end
  end
end