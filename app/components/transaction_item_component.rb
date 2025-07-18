class TransactionItemComponent < ViewComponent::Base
  VARIANTS = {
    default: "bg-container hover:bg-container-hover",
    selected: "bg-primary-50 [data-theme=dark]:bg-primary-900"
  }.freeze

  attr_reader :entry, :transaction, :selected, :view_ctx, :balance_trend

  def initialize(entry:, selected: false, view_ctx: "global", balance_trend: nil)
    @entry = entry
    @transaction = entry.entryable
    @selected = selected
    @view_ctx = view_ctx
    @balance_trend = balance_trend
  end

  def container_classes
    class_names(
      "grid grid-cols-12 items-center text-primary text-sm font-medium p-4 lg:p-4 rounded-lg transition-colors",
      "border border-transparent",
      selected ? VARIANTS[:selected] : VARIANTS[:default],
      entry.excluded ? "opacity-50 text-gray-400" : ""
    )
  end

  def focused?
    @focused_record == entry || @focused_record == transaction
  end

  def transfer?
    transaction.transfer?
  end

  def one_time?
    transaction.one_time?
  end

  def has_merchant_logo?
    transaction.merchant&.logo_url.present?
  end

  def merchant_logo_url
    transaction.merchant&.logo_url
  end

  def transaction_path
    if transfer? && transaction.transfer.present?
      transfer_path(transaction.transfer)
    else
      entry_path(entry)
    end
  end

  def account_path_with_focus
    account_path(entry.account, tab: "transactions", focused_record_id: entry.id)
  end

  def formatted_amount
    if transfer? && view_ctx == "global"
      "+/- #{format_money(entry.amount_money.abs)}"
    else
      format_money(-entry.amount_money)
    end
  end

  def amount_classes
    entry.amount.negative? ? "text-green-600" : ""
  end

  def balance_amount
    if balance_trend&.trend
      format_money(balance_trend.trend.current)
    else
      "--"
    end
  end

  def balance_classes
    balance_trend&.trend ? "font-medium text-sm text-primary" : "font-medium text-sm text-gray-400"
  end

  def name_column_classes
    view_ctx == "global" ? "lg:col-span-8" : "lg:col-span-6"
  end
end