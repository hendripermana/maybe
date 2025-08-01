# frozen_string_literal: true

module Ui
  # Preview for the BalanceDisplay component
  class BalanceDisplayComponentPreview < ViewComponent::Preview
    # @!group Amounts

    # @label Positive Amount
    def positive_amount
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75))
    end

    # @label Negative Amount
    def negative_amount
      render(Ui::BalanceDisplayComponent.new(amount: -450.25))
    end

    # @label Zero Amount
    def zero_amount
      render(Ui::BalanceDisplayComponent.new(amount: 0))
    end

    # @!endgroup

    # @!group Variants

    # @label Default
    def default_variant
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, variant: :default))
    end

    # @label Primary
    def primary_variant
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, variant: :primary))
    end

    # @label Success
    def success_variant
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, variant: :success))
    end

    # @label Warning
    def warning_variant
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, variant: :warning))
    end

    # @label Destructive
    def destructive_variant
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, variant: :destructive))
    end

    # @!endgroup

    # @!group Sizes

    # @label Extra Small
    def xs_size
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, size: :xs))
    end

    # @label Small
    def sm_size
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, size: :sm))
    end

    # @label Medium (Default)
    def md_size
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, size: :md))
    end

    # @label Large
    def lg_size
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, size: :lg))
    end

    # @label Extra Large
    def xl_size
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, size: :xl))
    end

    # @label 2XL
    def xxl_size
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, size: :"2xl"))
    end

    # @label 3XL
    def xxxl_size
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, size: :"3xl"))
    end

    # @!endgroup

    # @!group Features

    # @label With Sign
    def with_sign
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, show_sign: true))
    end

    # @label With Indicator
    def with_indicator
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, show_indicator: true))
    end

    # @label With Currency
    def with_currency
      render(Ui::BalanceDisplayComponent.new(amount: 1250.75, currency: "EUR"))
    end

    # @!endgroup
  end
end
