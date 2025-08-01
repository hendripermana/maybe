# frozen_string_literal: true

module Ui
  # TransactionBadge component for displaying transaction types/statuses
  # Follows Shadcn design principles with theme support
  class TransactionBadgeComponent < BaseComponent
    TRANSACTION_TYPES = {
      income: {
        label: "Income",
        variant: "success",
        icon: "arrow-down-left"
      },
      expense: {
        label: "Expense",
        variant: "destructive",
        icon: "arrow-up-right"
      },
      transfer: {
        label: "Transfer",
        variant: "primary",
        icon: "repeat"
      },
      investment: {
        label: "Investment",
        variant: "warning",
        icon: "trending-up"
      },
      refund: {
        label: "Refund",
        variant: "success",
        icon: "rotate-ccw"
      },
      adjustment: {
        label: "Adjustment",
        variant: "default",
        icon: "pencil"
      }
    }.freeze

    TRANSACTION_STATUSES = {
      pending: {
        label: "Pending",
        variant: "warning",
        icon: "clock"
      },
      cleared: {
        label: "Cleared",
        variant: "success",
        icon: "check"
      },
      reconciled: {
        label: "Reconciled",
        variant: "primary",
        icon: "check-circle"
      },
      void: {
        label: "Void",
        variant: "destructive",
        icon: "x-circle"
      }
    }.freeze

    def initialize(transaction_type: nil, transaction_status: nil, custom_label: nil, show_icon: true, size: :sm, **options)
      type_config = TRANSACTION_TYPES[transaction_type.to_sym] if transaction_type
      status_config = TRANSACTION_STATUSES[transaction_status.to_sym] if transaction_status

      config = type_config || status_config || { label: custom_label, variant: :default, icon: "tag" }

      super(variant: config[:variant], size: size, **options)

      @label = custom_label || config[:label]
      @icon = config[:icon]
      @show_icon = show_icon
    end

    private

      attr_reader :label, :icon, :show_icon
  end
end
