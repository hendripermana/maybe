# Computes a simple monthly amortization schedule for fixed-rate or zero-interest loans.
# Inputs: outstanding (Money), rate (% APR decimal), term_months (Integer), due_day (1..31)
#
# Contract:
#   schedule = AmortizationSchedule.compute(outstanding:, rate:, term_months:, due_day:, start_date:)
#   schedule.installments -> [ { due_date:, amount:, principal:, interest: } ]
#   schedule.amount_due(on:) -> Money for the installment period containing the date
#
# Notes:
# - For zero-interest, amount = outstanding / remaining_periods
# - Due date clamps to end-of-month for short months
# - FX is not handled here; amounts are in the loan account currency
class AmortizationSchedule
  Installment = Struct.new(:due_date, :amount, :principal, :interest, keyword_init: true)

  attr_reader :currency

  def self.compute(outstanding:, rate:, term_months:, due_day:, start_date:)
    new(outstanding:, rate:, term_months:, due_day:, start_date:)
  end

  def initialize(outstanding:, rate:, term_months:, due_day:, start_date:)
    @outstanding = outstanding.is_a?(Money) ? outstanding : Money.new(outstanding, Money.default_currency)
    @rate = rate.to_d
    @term_months = term_months.to_i
    @due_day = due_day.to_i
    @start_date = start_date
    @currency = @outstanding.currency
    @installments = nil
  end

  def installments
    @installments ||= build_installments
  end

  def amount_due(on: Date.current)
    inst = installments.find { |i| period_window(i.due_date).cover?(on) }
    inst ? Money.new(inst.amount, currency) : Money.new(0, currency)
  end

  private
    attr_reader :outstanding, :rate, :term_months, :due_day, :start_date

    def build_installments
      return [] if term_months <= 0 || outstanding.amount <= 0

      months = term_months
      annual_rate = rate / 100.0
      monthly_rate = annual_rate / 12.0
      current_principal = outstanding.amount
      list = []

      months.times do |i|
        base = (start_date >> i)
        # If this is the first installment and start_date already reflects origination/due anchor,
        # clamp to end-of-month without shifting before the start.
        # Use 31 as a symbolic EOM anchor: clamp_to_month_end will adjust for Feb, Apr, etc.
        target_day = (due_day == 31 ? 31 : [ due_day, 28 ].min)
        begin
          due = clamp_to_month_end(base.change(day: target_day))
        rescue Date::Error
          # If target_day is invalid for this month (e.g., 31 in April), move to last day of month
          due = Date.civil(base.year, base.month, -1)
        end

        if monthly_rate.zero?
          principal = (current_principal / (months - i)).round(2)
          interest = 0
          amount = principal
        else
          payment = (outstanding.amount * monthly_rate * (1 + monthly_rate)**months) / ((1 + monthly_rate)**months - 1)
          interest = (current_principal * monthly_rate).round(2)
          principal = (payment - interest).round(2)
          amount = (principal + interest).round(2)
        end

        list << Installment.new(due_date: due, amount: amount, principal: principal, interest: interest)
        current_principal = (current_principal - principal)
        current_principal = 0 if current_principal.negative?
      end

      list
    end

    def clamp_to_month_end(date)
      last_day = Date.civil(date.year, date.month, -1).day
      date.change(day: [ date.day, last_day ].min)
    end

    def period_window(due_date)
      prev = clamp_to_month_end((due_date << 1).change(day: due_day))
      (prev.succ..due_date)
    end
end
