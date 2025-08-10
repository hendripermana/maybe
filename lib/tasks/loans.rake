namespace :loans do
  desc "Run daily due check for loans"
  task due_check: :environment do
    DebtDueCheckerJob.perform_now
  end
end
