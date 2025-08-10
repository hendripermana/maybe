# Debt lifecycle & repayment design (Phase 1 — design notes only)
#
# Purpose: Introduce derived debt status, monthly schedules, and flexible repayments
# without changing existing double-entry, FX, materialization, or cache behavior.
#
# Status model (derived; not persisted):
#   Values: :active, :in_grace, :overdue, :paid_off
#   Inputs: next_due_date, amount_due_period, grace_days (default 5), outstanding
#   Rules:
#     - paid_off     if outstanding <= tolerance (1 minor currency unit)
#     - overdue      if today > next_due_date + grace_days AND amount_due_period not fully paid
#     - in_grace     if next_due_date < today <= next_due_date + grace_days AND not fully paid
#     - active       otherwise
#   Contract (planned): LoanStatusComputer.new(loan, as_of: Date.current)
#     .status, .next_due_date, .amount_due_period, .days_past_due
#   Notes: purely reads transactions/entries and any schedule metadata; no posting.
#
# Scheduling (standard loans and personal loans):
#   - Monthly cadence using origination_date, term_months, due_day (default = origination day)
#   - Fixed-rate amortization for now; variable-rate hook reserved for later
#   - For credit card–like debts (future): statement_day, due_day, min_payment -> hook only
#   Contract (planned): AmortizationSchedule.compute(outstanding:, rate:, term_months:, due_day:)
#     .installments, .amount_due(on: date)
#
# Flexible repayments (respect existing transfer-based postings):
#   - Partial payment: already supported via Transfer::Creator to Loan accounts (kind: loan_payment)
#     amount_due calculation must subtract partials within the period
#   - Early payment (extra principal):
#       EarlyPaymentService.call!(loan:, amount:, mode: :shorten_term|:reduce_payment, date:)
#       Default mode: :shorten_term; recompute schedule from new outstanding only
#       Posts DR Debt (principal), CR Cash via existing transfer pipeline; then recompute schedule
#   - Reschedule: RescheduleService.call!(loan:, new_term_months:, new_rate: nil, new_due_day: nil,
#       effective_date:, reason:)
#       Freeze prior schedule, bump schedule_version, recompute from outstanding@effective_date
#       Preserve history; audit with event "debt_rescheduled"
#
# Data model additions (Phase 2 migrations; additive only):
#   loans: due_day:integer, grace_days:integer (default: 5), schedule_version:integer (default: 1),
#          rescheduled_at:datetime, reschedule_reason:text
#   Optional future: min_payment_cents for CC-like debts
#
# UI (non-blocking follow-ups):
#   - Debt index (accounts list liabilities): status chip, progress bar (paid/total),
#     “next due • date” + “amount due”
#   - Debt show: prominent status + progress; actions: Make Payment (prefilled transfer),
#     Early Payment, Reschedule
#   - Notifications: daily job DebtDueCheckerJob computes transitions and queues reminders
#
# Safety/constraints:
#   - Use Current.family ownership checks in services; cash/loan accounts must belong to same family
#   - Idempotency for EarlyPaymentService & RescheduleService (deterministic keys or last action ids)
#   - Do NOT alter double-entry, FX conversion (Money.exchange_to), materialization, or cache key strategy
#
# Edge cases to cover in tests:
#   - Cross-currency payments (loan vs. cash currency)
#   - Zero-interest loans (monthly payment reduces to principal/term)
#   - Partial payments keeping status in_grace/overdue until fully covered for the period
#   - Paid off tolerance (<= 1 unit of currency)

class Loan < ApplicationRecord
  include Accountable

  SUBTYPES = {
    "mortgage" => { short: "Mortgage", long: "Mortgage" },
    "student" => { short: "Student", long: "Student Loan" },
    "auto" => { short: "Auto", long: "Auto Loan" },
    "other" => { short: "Other", long: "Other Loan" }
  }.freeze

  # Virtual attribute used only during origination flow
  attr_accessor :imported

  # Basic validations for new metadata (kept permissive for backward compatibility)
  validates :debt_kind, inclusion: { in: %w[institutional personal] }, allow_nil: true
  validates :counterparty_type, inclusion: { in: %w[institution person] }, allow_nil: true
  validates :counterparty_name, length: { maximum: 255 }, allow_nil: true

  def monthly_payment
    return nil if term_months.nil? || interest_rate.nil? || rate_type.nil? || rate_type != "fixed"
    return Money.new(0, account.currency) if account.loan.original_balance.amount.zero? || term_months.zero?

    annual_rate = interest_rate / 100.0
    monthly_rate = annual_rate / 12.0

    if monthly_rate.zero?
      payment = account.loan.original_balance.amount / term_months
    else
      payment = (account.loan.original_balance.amount * monthly_rate * (1 + monthly_rate)**term_months) / ((1 + monthly_rate)**term_months - 1)
    end

    Money.new(payment.round, account.currency)
  end

  def original_balance
    # Prefer initial_balance column if present, fallback to first valuation amount
    base_amount = if initial_balance.present?
      initial_balance
    else
      account.first_valuation_amount
    end
    Money.new(base_amount, account.currency)
  end

  class << self
    def color
      "#D444F1"
    end

    def icon
      "hand-coins"
    end

    def classification
      "liability"
    end
  end
end
