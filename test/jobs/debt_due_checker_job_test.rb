require "test_helper"

class DebtDueCheckerJobTest < ActiveJob::TestCase
  test "runs without error and logs for loans" do
    assert_nothing_raised do
      perform_enqueued_jobs do
        DebtDueCheckerJob.perform_now
      end
    end
  end
end
