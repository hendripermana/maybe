# frozen_string_literal: true

require "test_helper"

class Ui::TransactionBadgeComponentTest < ViewComponent::TestCase
  include ComponentTestingSuiteHelper

  def test_renders_transaction_type_badge
    render_inline(Ui::TransactionBadgeComponent.new(transaction_type: :income))

    assert_text "Income"
    assert_selector ".bg-success"
  end

  def test_renders_different_transaction_types
    render_inline(Ui::TransactionBadgeComponent.new(transaction_type: :income))
    assert_text "Income"
    assert_selector ".bg-success"

    render_inline(Ui::TransactionBadgeComponent.new(transaction_type: :expense))
    assert_text "Expense"
    assert_selector ".bg-destructive"

    render_inline(Ui::TransactionBadgeComponent.new(transaction_type: :transfer))
    assert_text "Transfer"
    assert_selector ".bg-primary"

    render_inline(Ui::TransactionBadgeComponent.new(transaction_type: :investment))
    assert_text "Investment"
    assert_selector ".bg-secondary"

    render_inline(Ui::TransactionBadgeComponent.new(transaction_type: :refund))
    assert_text "Refund"
    assert_selector ".bg-warning"

    render_inline(Ui::TransactionBadgeComponent.new(transaction_type: :adjustment))
    assert_text "Adjustment"
    assert_selector ".bg-muted"
  end

  def test_renders_transaction_status_badge
    render_inline(Ui::TransactionBadgeComponent.new(transaction_status: :pending))

    assert_text "Pending"
    assert_selector ".bg-warning"
  end

  def test_renders_different_transaction_statuses
    render_inline(Ui::TransactionBadgeComponent.new(transaction_status: :pending))
    assert_text "Pending"
    assert_selector ".bg-warning"

    render_inline(Ui::TransactionBadgeComponent.new(transaction_status: :cleared))
    assert_text "Cleared"
    assert_selector ".bg-success"

    render_inline(Ui::TransactionBadgeComponent.new(transaction_status: :reconciled))
    assert_text "Reconciled"
    assert_selector ".bg-primary"

    render_inline(Ui::TransactionBadgeComponent.new(transaction_status: :void))
    assert_text "Void"
    assert_selector ".bg-destructive"
  end

  def test_renders_custom_label
    render_inline(Ui::TransactionBadgeComponent.new(custom_label: "Custom"))

    assert_text "Custom"
  end

  def test_renders_with_icon
    render_inline(Ui::TransactionBadgeComponent.new(
      transaction_type: :income,
      show_icon: true
    ))

    assert_selector "svg"
  end

  def test_renders_without_icon
    render_inline(Ui::TransactionBadgeComponent.new(
      transaction_type: :income,
      show_icon: false
    ))

    assert_no_selector "svg"
  end

  def test_renders_different_sizes
    render_inline(Ui::TransactionBadgeComponent.new(transaction_type: :income, size: :sm))
    assert_selector ".text-xs"

    render_inline(Ui::TransactionBadgeComponent.new(transaction_type: :income, size: :md))
    assert_selector ".text-sm"

    render_inline(Ui::TransactionBadgeComponent.new(transaction_type: :income, size: :lg))
    assert_selector ".text-base"
  end

  def test_theme_switching
    test_component_comprehensively(
      Ui::TransactionBadgeComponent.new(transaction_type: :income)
    )
  end

  def test_accessibility
    render_inline(Ui::TransactionBadgeComponent.new(
      transaction_type: :income,
      show_icon: true
    ))

    # Check for proper ARIA attributes on icon
    assert_selector "svg[aria-hidden='true']"
  end

  def test_renders_with_custom_class
    render_inline(Ui::TransactionBadgeComponent.new(
      transaction_type: :income,
      class: "custom-class"
    ))

    assert_selector ".custom-class"
  end
end
