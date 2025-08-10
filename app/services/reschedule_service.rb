# Bumps schedule version and stores reschedule metadata; uses materialized outstanding as baseline.
# Idempotent by deterministic key that doesn't change across retries:
# "#{loan.account.id}|reschedule|#{effective_date}|#{new_term_months}|#{new_rate}|#{new_due_day}"
class RescheduleService
  Result = Struct.new(:success?, :loan, :error, keyword_init: true)

  def self.call!(loan:, new_term_months:, new_rate: nil, new_due_day: nil, effective_date:, reason:, family: Current.family)
    new(loan:, new_term_months:, new_rate:, new_due_day:, effective_date:, reason:, family:).call!
  end

  def initialize(loan:, new_term_months:, new_rate:, new_due_day:, effective_date:, reason:, family:)
    account = loan.is_a?(Loan) ? loan.account : loan
    @loan = family.accounts.find(account.id).loan
    @family = family
    @new_term_months = new_term_months
    @new_rate = new_rate
    @new_due_day = new_due_day
    @effective_date = effective_date
    @reason = reason
  end

  def call!
    with_idempotency(key) do
      loan.with_lock do
        loan.update!(
          term_months: new_term_months.presence || loan.term_months,
          interest_rate: new_rate.presence || loan.interest_rate,
          due_day: new_due_day.presence || loan.due_day,
          schedule_version: loan.schedule_version.to_i + 1,
          rescheduled_at: Time.current,
          reschedule_reason: reason
        )
      end
    end

    Result.new(success?: true, loan: loan)
  rescue => e
    Result.new(success?: false, error: e.message)
  end

  private
    attr_reader :loan, :family, :new_term_months, :new_rate, :new_due_day, :effective_date, :reason

    def key
      [ loan.account.id, "reschedule", effective_date, new_term_months.presence, new_rate.presence, new_due_day.presence ].join("|")
    end

    def with_idempotency(k)
      return loan if loan.rescheduled_at.present? && loan.reschedule_reason.to_s.include?(k)
      yield
      # Append key to reason to avoid duplicate bump; non-invasive storage
      loan.update_column(:reschedule_reason, [ loan.reschedule_reason, k ].compact.join(" | "))
    end
end
