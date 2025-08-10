#!/usr/bin/env rails runner

family = Family.first || abort("No family found")
Current.set(session: OpenStruct.new(user: family.users.first)) do
  puts "== QA Debt Script =="

  cash = family.accounts.where(accountable_type: "Depository").first || family.accounts.assets.first
  abort("No cash account available") unless cash

  # Create a USD loan
  result = DebtOriginationService.call!(
    family: family,
    params: { name: "QA USD Loan", currency: family.currency, initial_balance: 1000, interest_rate: 5, term_months: 12, rate_type: "fixed" }
  )
  loan_acc = result.account
  puts "Created loan: #{loan_acc.name} balance=#{loan_acc.balance_money.format}"

  # Partial payment (normal transfer)
  Transfer::Creator.new(family: family, source_account_id: cash.id, destination_account_id: loan_acc.id, date: Date.current, amount: 50).create
  puts "After partial payment: balance=#{loan_acc.reload.balance_money.format}"

  # Early payment
  ep = EarlyPaymentService.new(loan: loan_acc.loan, amount: 25, mode: :shorten_term, date: Date.current, family: family)
  ep.call!
  puts "After early payment: balance=#{loan_acc.reload.balance_money.format}"

  # Reschedule
  RescheduleService.call!(loan: loan_acc.loan, new_term_months: 10, new_rate: nil, new_due_day: nil, effective_date: Date.current, reason: "QA")
  puts "After reschedule: schedule_version=#{loan_acc.reload.loan.schedule_version}"

  status = LoanStatusComputer.new(loan_acc.loan, as_of: Date.current).call
  puts "Status: #{status.status} next_due=#{status.next_due_date} amount_due=#{status.amount_due_period.format} progress=#{(status.progress*100).round}%"
end
