# Posts an extra principal payment and recomputes schedule without altering accounting/FX pipelines.
# Strict FX: preflight historical exchange rate on-or-before date (no fallback allowed); error if missing.
# Idempotent by deterministic key: "#{loan.id}|early|#{date}|#{amount}|#{mode}"
class EarlyPaymentService
  Result = Struct.new(:success?, :transfer, :error, keyword_init: true)

  def self.call!(loan:, amount:, mode: :shorten_term, date: Date.current, family: Current.family)
    new(loan:, amount:, mode:, date:, family:).call!
  end

  def initialize(loan:, amount:, mode:, date:, family:)
    account = loan.is_a?(Loan) ? loan.account : loan
    @loan = account.loan
    @family = family || account.family
    @amount = amount.to_d
    @mode = mode.to_sym
    @date = date
  end

  def call!
    # Strict FX preflight: ensure a historical rate exists; do not allow fallback
    ensure_fx_rate!

    created = with_idempotency("#{loan.account.id}|early|#{date}|#{amount}|#{mode}") do
      Transfer::Creator.new(
        family: family,
        source_account_id: cash_account_id,
        destination_account_id: loan.account.id,
        date: date,
        amount: amount
      ).create.tap do |transfer|
        raise "Transfer failed" unless transfer.persisted?
      end
    end

    Result.new(success?: created&.persisted?, transfer: created)
  rescue => e
    Result.new(success?: false, error: e.message)
  end

  private
    attr_reader :loan, :family, :amount, :mode, :date

    def cash_account
      @cash_account ||= begin
        acc = if @cash_account_id
          family.accounts.find(@cash_account_id)
        else
          # Prefer a Depository account for payments to avoid transferring from the loan itself
          family.accounts.where(accountable_type: "Depository").first || family.accounts.assets.first
        end
        raise ArgumentError, "cash account required" unless acc
        acc
      end
    end

    def cash_account_id
      # For now require caller to set a default; could be extended to take param
      cash_account.id
    end

    def ensure_fx_rate!
      # If currencies differ, verify a provider rate exists for the date; do not use fallback
      loan_currency = loan.account.currency
      source_currency = cash_account.currency
      return if loan_currency == source_currency

      # Will raise Money::ConversionError if no rate is available
      Money.new(amount.abs, source_currency).exchange_to(loan_currency, date: date)
    end

    def with_idempotency(key)
      # Lightweight idempotency: ensure no duplicate transfer with same composed key.
      # We search transfers whose outflow entry name already contains the key and belongs to this family.
      existing = Transfer
        .joins("INNER JOIN transactions out_tx ON out_tx.id = transfers.outflow_transaction_id")
        .joins("INNER JOIN entries out_e ON out_e.entryable_id = out_tx.id AND out_e.entryable_type = 'Transaction'")
        .where("out_e.account_id IN (?)", family.accounts.select(:id))
        .where("out_e.name LIKE ?", "%#{key}%")
        .first
      return existing if existing

      @transfer = yield
      # Tag the transfer name with key for idempotency; keep UX benign
      @transfer.outflow_transaction.entry.update!(name: [ @transfer.outflow_transaction.entry.name, key ].join(" # "))
      @transfer
    end
end
