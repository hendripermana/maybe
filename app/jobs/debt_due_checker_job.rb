# Runs daily to compute status and enqueue reminders for due-soon, grace, and overdue.
class DebtDueCheckerJob < ApplicationJob
  queue_as :default

  def perform
    Family.find_each do |family|
      # Current.family is delegated from Current.user. Establish a minimal session
      # with the family's owner so downstream code sees Current.family.
      session = OpenStruct.new(user: family.users.first)
      Current.set(session: session) do
        family.accounts.liabilities.where(accountable_type: "Loan").find_each do |account|
          loan = account.loan
          status = LoanStatusComputer.new(loan, as_of: Date.current).call
          notify_if_needed(family, account, status)
        end
      end
    end
  end

  private
    def notify_if_needed(family, account, status)
      # Minimal stub: log transitions and enqueue future mailer when available
      case status.status
      when :overdue
        Rails.logger.info("[DebtDueChecker] OVERDUE #{family.id}/#{account.id} due=#{status.next_due_date} amt=#{status.amount_due_period.format}")
        ReminderMailer.overdue(account.loan)
      when :in_grace
        Rails.logger.info("[DebtDueChecker] IN_GRACE #{family.id}/#{account.id} due=#{status.next_due_date} amt=#{status.amount_due_period.format}")
        ReminderMailer.in_grace(account.loan)
      when :active
        # H-3 reminder
        if (status.next_due_date - Date.current).to_i <= 3
          Rails.logger.info("[DebtDueChecker] DUE_SOON #{family.id}/#{account.id} due=#{status.next_due_date} amt=#{status.amount_due_period.format}")
          ReminderMailer.due_soon(account.loan)
        end
      end
    end
end
