require "test_helper"

class AmortizationScheduleTest < ActiveSupport::TestCase
  test "zero interest splits evenly by months and clamps due dates" do
    money = Money.new(1000, "USD")
    sched = AmortizationSchedule.compute(outstanding: money, rate: 0, term_months: 4, due_day: 31, start_date: Date.new(2024, 1, 31))
    inst = sched.installments
    assert_equal 4, inst.size
    assert_equal Date.new(2024, 1, 31), inst[0].due_date
    assert_equal Date.new(2024, 2, 29), inst[1].due_date # Feb clamp
    assert_in_delta 250, inst[0].amount, 0.01
    assert_equal inst[0].amount, inst[0].principal
    assert_equal 0, inst[0].interest
  end
end
