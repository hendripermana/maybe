# frozen_string_literal: true

require "test_helper"

class Ui::AccountCardComponentTest < ViewComponent::TestCase
  def setup
    @account = OpenStruct.new(
      name: "Checking Account",
      accountable_type: "Depository",
      institution_name: "Example Bank",
      balance: 1250.75,
      currency: "USD",
      available_balance: 1350.75,
      can_sync?: true
    )
  end

  def test_renders_account_card
    render_inline(Ui::AccountCardComponent.new(account: @account))

    assert_text "Checking Account"
    assert_text "Depository"
    assert_text "Example Bank"
    assert_text "$1,250.75" # This assumes format_currency helper works as expected
  end

  def test_renders_without_balance
    render_inline(Ui::AccountCardComponent.new(account: @account, show_balance: false))

    assert_text "Checking Account"
    assert_no_text "Current balance"
    assert_no_text "$1,250.75"
  end

  def test_renders_without_actions
    render_inline(Ui::AccountCardComponent.new(account: @account, show_actions: false))

    assert_text "Checking Account"
    assert_no_selector ".dropdown"
  end

  def test_renders_different_variants
    render_inline(Ui::AccountCardComponent.new(account: @account, variant: :primary))
    assert_selector ".bg-blue-50"

    render_inline(Ui::AccountCardComponent.new(account: @account, variant: :success))
    assert_selector ".bg-green-50"
  end

  def test_renders_different_sizes
    render_inline(Ui::AccountCardComponent.new(account: @account, size: :sm))
    assert_selector ".p-3"

    render_inline(Ui::AccountCardComponent.new(account: @account, size: :md))
    assert_selector ".p-4"

    render_inline(Ui::AccountCardComponent.new(account: @account, size: :lg))
    assert_selector ".p-5"
  end

  def test_renders_negative_balance_with_appropriate_color
    @account.balance = -450.25
    render_inline(Ui::AccountCardComponent.new(account: @account))

    assert_selector ".text-red-600"
  end
end
