class ReminderMailer < ApplicationMailer
  default from: ENV["DEFAULT_SENDER_EMAIL"].presence || "no-reply@example.com"

  def due_soon(loan)
    Rails.logger.info("[ReminderMailer] due_soon loan=#{loan.id}")
  end

  def in_grace(loan)
    Rails.logger.info("[ReminderMailer] in_grace loan=#{loan.id}")
  end

  def overdue(loan)
    Rails.logger.info("[ReminderMailer] overdue loan=#{loan.id}")
  end
end
