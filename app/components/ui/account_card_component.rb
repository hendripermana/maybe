# frozen_string_literal: true

module Ui
  # AccountCard component for displaying account information
  # Follows Shadcn design principles with theme support
  class AccountCardComponent < BaseComponent
    VARIANTS = {
      default: "bg-white border-gray-200 [data-theme=dark]:bg-gray-800 [data-theme=dark]:border-gray-700",
      primary: "bg-blue-50 border-blue-200 [data-theme=dark]:bg-blue-900/20 [data-theme=dark]:border-blue-800",
      success: "bg-green-50 border-green-200 [data-theme=dark]:bg-green-900/20 [data-theme=dark]:border-green-800",
      warning: "bg-yellow-50 border-yellow-200 [data-theme=dark]:bg-yellow-900/20 [data-theme=dark]:border-yellow-800",
      destructive: "bg-red-50 border-red-200 [data-theme=dark]:bg-red-900/20 [data-theme=dark]:border-red-800"
    }.freeze

    SIZES = {
      sm: "p-3",
      md: "p-4",
      lg: "p-5"
    }.freeze

    def initialize(account:, show_balance: true, show_actions: true, variant: :default, size: :md, **options)
      super(variant: variant, size: size, **options)
      @account = account
      @show_balance = show_balance
      @show_actions = show_actions
    end

    private

    attr_reader :account, :show_balance, :show_actions

    def container_classes
      build_classes(
        "rounded-lg border shadow-sm",
        VARIANTS[variant],
        SIZES[size]
      )
    end

    def account_type_icon
      case account.accountable_type
      when "Depository" then "building-bank"
      when "CreditCard" then "credit-card"
      when "Investment" then "trending-up"
      when "Loan" then "landmark"
      when "Property" then "home"
      when "Vehicle" then "car"
      when "Crypto" then "bitcoin"
      when "OtherAsset" then "package"
      when "OtherLiability" then "file-minus"
      else "circle-dollar-sign"
      end
    end

    def account_type_color
      case account.accountable_type
      when "Depository" then "blue-600"
      when "CreditCard" then "purple-600"
      when "Investment" then "green-600"
      when "Loan" then "red-600"
      when "Property" then "amber-600"
      when "Vehicle" then "cyan-600"
      when "Crypto" then "orange-600"
      when "OtherAsset" then "emerald-600"
      when "OtherLiability" then "rose-600"
      else "gray-600"
      end
    end

    def account_balance_class
      if account.balance.to_i.negative?
        "text-red-600 [data-theme=dark]:text-red-400"
      else
        "text-green-600 [data-theme=dark]:text-green-400"
      end
    end
  end
end