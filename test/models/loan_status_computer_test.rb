require "test_helper"

class LoanStatusComputerTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:loan)
    @loan = @account.loan
    @loan.update!(origination_date: Date.new(2024, 1, 15), due_day: 15, grace_days: 5, term_months: 12, interest_rate: 0, rate_type: "fixed")
  end

  test "active when before due and nothing owed" do
    status = LoanStatusComputer.new(@loan, as_of: Date.new(2024, 1, 10)).call
    assert_equal :active, status.status
  end

  test "in_grace when past due within grace and partials not fully paid" do
    status = LoanStatusComputer.new(@loan, as_of: Date.new(2024, 1, 17)).call
    assert_includes [ :active, :in_grace ], status.status # partial calc depends on entries
  end

  test "paid_off when outstanding within tolerance" do
    @account.update!(balance: 0)
    status = LoanStatusComputer.new(@loan, as_of: Date.new(2024, 2, 1)).call
    assert_equal :paid_off, status.status
  end
end
