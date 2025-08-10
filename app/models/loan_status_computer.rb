# Computes derived debt status and due amounts for a Loan account without changing postings.
# Inputs: loan (Loan), as_of (Date)
# Reads: latest materialized balance (Account#balance for loan account), schedule metadata on Loan,
#        entries/transactions for partial payments within the current period.
# Outputs: status, next_due_date, amount_due_period (Money), days_past_due, outstanding (Money), progress (0..1)
#
# Status rules:
# - paid_off  if outstanding <= tolerance (1 minor unit)
# - overdue   if today > next_due_date + grace_days AND amount_due_period not fully paid
# - in_grace  if next_due_date < today <= next_due_date + grace_days AND not fully paid
# - active    otherwise
class LoanStatusComputer
  TOLERANCE = 1.to_d

  Result = Struct.new(:status, :next_due_date, :amount_due_period, :days_past_due, :outstanding, :progress, keyword_init: true)

  def initialize(loan, as_of: Date.current)
    @loan = loan
    @as_of = as_of
  end

  def call
    # Ensure we read the freshest account state (tests may update balance just prior to calling)
    loan.account.reload
    currency = account.currency
    outstanding = account.balance_money.abs

    # Determine due_day default and grace days
    due_day = loan.due_day || (loan.origination_date&.day || 1)
    grace_days = loan.grace_days.presence || 5

    start_date = loan.origination_date || account.start_date
    schedule = AmortizationSchedule.compute(
      outstanding: outstanding,
      rate: loan.interest_rate || 0,
      term_months: loan.term_months || 0,
      due_day: due_day,
      start_date: start_date
    )

    next_due = next_due_date(as_of, due_day)
    amount_due = scheduled_amount_for_period(schedule, on: as_of)
    amount_paid = principal_paid_in_period(on: as_of)
    amount_due_period = [ amount_due.amount - amount_paid.amount, 0 ].max
    amount_due_money = Money.new(amount_due_period, currency)

    status = compute_status(as_of:, next_due:, grace_days:, amount_due_remaining: amount_due_money, outstanding: outstanding)

    progress = compute_progress(outstanding: outstanding)
    days_past_due = as_of > next_due ? (as_of - next_due).to_i : 0

    Result.new(status:, next_due_date: next_due, amount_due_period: amount_due_money, days_past_due:, outstanding:, progress: progress)
  end

  private
    attr_reader :loan, :as_of

    def account
      loan.account
    end

    def as_of_period_bounds(due_day)
      # Determine current period window based on due_day
      month_due = Date.new(as_of.year, as_of.month, 1).change(day: [ due_day, 28 ].min)
      due = clamp_to_month_end(month_due)
      prev_due = clamp_to_month_end((due << 1).change(day: due_day))
      (prev_due.succ..due)
    end

    def next_due_date(date, due_day = nil)
      dday = due_day || loan.due_day || (loan.origination_date&.day || 1)
      candidate = Date.new(date.year, date.month, 1).change(day: [ dday, 28 ].min)
      due = clamp_to_month_end(candidate)
      due >= date ? due : clamp_to_month_end((candidate >> 1))
    end

    def scheduled_amount_for_period(schedule, on:)
      schedule.amount_due(on: on)
    end

    def principal_paid_in_period(on:)
      # Sum principal reductions via transfers into the loan account within the current period window
      bounds = as_of_period_bounds(loan.due_day || (loan.origination_date&.day || 1))
      entries = account.entries
                       .where(entryable_type: "Transaction")
                       .where(date: bounds)
      money = entries.sum(:amount)
      Money.new([ money, 0 ].min.abs, account.currency)
    end

    def compute_status(as_of:, next_due:, grace_days:, amount_due_remaining:, outstanding:)
      return :paid_off if outstanding.amount.abs <= TOLERANCE

      grace_end = next_due + grace_days
      if as_of > grace_end && amount_due_remaining.amount > 0
        :overdue
      elsif as_of > next_due && as_of <= grace_end && amount_due_remaining.amount > 0
        :in_grace
      else
        :active
      end
    end

    def compute_progress(outstanding:)
      original = loan.original_balance
      return 0.0 if original.amount.to_d <= 0
      paid = (original.amount - outstanding.amount).clamp(0, original.amount)
      (paid / original.amount.to_d).to_f
    end

    def clamp_to_month_end(date)
      last_day = Date.civil(date.year, date.month, -1).day
      date.change(day: [ date.day, last_day ].min)
    end
end
