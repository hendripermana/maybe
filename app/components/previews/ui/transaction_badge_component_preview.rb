# frozen_string_literal: true

module Ui
  # Preview for the TransactionBadge component
  class TransactionBadgeComponentPreview < ViewComponent::Preview
    # @!group Transaction Types
    
    # @label Income
    def income_type
      render(Ui::TransactionBadgeComponent.new(transaction_type: :income))
    end

    # @label Expense
    def expense_type
      render(Ui::TransactionBadgeComponent.new(transaction_type: :expense))
    end

    # @label Transfer
    def transfer_type
      render(Ui::TransactionBadgeComponent.new(transaction_type: :transfer))
    end

    # @label Investment
    def investment_type
      render(Ui::TransactionBadgeComponent.new(transaction_type: :investment))
    end

    # @label Refund
    def refund_type
      render(Ui::TransactionBadgeComponent.new(transaction_type: :refund))
    end

    # @label Adjustment
    def adjustment_type
      render(Ui::TransactionBadgeComponent.new(transaction_type: :adjustment))
    end

    # @!endgroup

    # @!group Transaction Statuses

    # @label Pending
    def pending_status
      render(Ui::TransactionBadgeComponent.new(transaction_status: :pending))
    end

    # @label Cleared
    def cleared_status
      render(Ui::TransactionBadgeComponent.new(transaction_status: :cleared))
    end

    # @label Reconciled
    def reconciled_status
      render(Ui::TransactionBadgeComponent.new(transaction_status: :reconciled))
    end

    # @label Void
    def void_status
      render(Ui::TransactionBadgeComponent.new(transaction_status: :void))
    end

    # @!endgroup

    # @!group Features

    # @label Custom Label
    def custom_label
      render(Ui::TransactionBadgeComponent.new(custom_label: "Custom Status"))
    end

    # @label Without Icon
    def without_icon
      render(Ui::TransactionBadgeComponent.new(transaction_type: :income, show_icon: false))
    end

    # @!endgroup

    # @!group Sizes

    # @label Small
    def small_size
      render(Ui::TransactionBadgeComponent.new(transaction_type: :income, size: :sm))
    end

    # @label Medium
    def medium_size
      render(Ui::TransactionBadgeComponent.new(transaction_type: :income, size: :md))
    end

    # @label Large
    def large_size
      render(Ui::TransactionBadgeComponent.new(transaction_type: :income, size: :lg))
    end

    # @!endgroup
  end
end