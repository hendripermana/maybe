# frozen_string_literal: true

module Ui
  # Preview for the AccountCard component
  class AccountCardComponentPreview < ViewComponent::Preview
    # @!group Account Types
    
    # @label Checking Account
    def checking_account
      render(Ui::AccountCardComponent.new(account: mock_account("Checking Account", "Depository", 1250.75)))
    end

    # @label Credit Card
    def credit_card
      render(Ui::AccountCardComponent.new(account: mock_account("Visa Signature", "CreditCard", -450.25)))
    end

    # @label Investment Account
    def investment_account
      render(Ui::AccountCardComponent.new(account: mock_account("Retirement Fund", "Investment", 45750.50)))
    end

    # @label Loan
    def loan
      render(Ui::AccountCardComponent.new(account: mock_account("Mortgage", "Loan", -325000.00)))
    end

    # @!endgroup

    # @!group Variants

    # @label Default
    def default_variant
      render(Ui::AccountCardComponent.new(account: mock_account("Checking Account", "Depository", 1250.75), variant: :default))
    end

    # @label Primary
    def primary_variant
      render(Ui::AccountCardComponent.new(account: mock_account("Checking Account", "Depository", 1250.75), variant: :primary))
    end

    # @!endgroup

    # @!group Features

    # @label Without Balance
    def without_balance
      render(Ui::AccountCardComponent.new(account: mock_account("Checking Account", "Depository", 1250.75), show_balance: false))
    end

    # @label Without Actions
    def without_actions
      render(Ui::AccountCardComponent.new(account: mock_account("Checking Account", "Depository", 1250.75), show_actions: false))
    end

    # @!endgroup

    private

    def mock_account(name, type, balance)
      OpenStruct.new(
        name: name,
        accountable_type: type,
        institution_name: "Example Bank",
        balance: balance,
        currency: "USD",
        available_balance: balance + 100,
        can_sync?: true
      )
    end
  end
end