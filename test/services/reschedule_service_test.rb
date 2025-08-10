require "test_helper"

class RescheduleServiceTest < ActiveSupport::TestCase
  setup do
    @family = families(:dylan_family)
    @loan = accounts(:loan).loan
  end

  test "bumps schedule_version and sets reschedule fields" do
    Current.set(family: @family) do
      old_version = @loan.schedule_version.to_i
      res = RescheduleService.call!(loan: @loan, new_term_months: 24, new_rate: 4.0, new_due_day: 10, effective_date: Date.current, reason: "Test")
      assert res.success?
      @loan.reload
      assert_equal old_version + 1, @loan.schedule_version
      assert @loan.rescheduled_at.present?
      assert_includes @loan.reschedule_reason.to_s, "reschedule|"
    end
  end
end
