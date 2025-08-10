require "test_helper"

class EarlyPaymentServiceTest < ActiveSupport::TestCase
  setup do
    @family = families(:dylan_family)
    @cash = accounts(:depository)
    @loan = accounts(:loan).loan
  end

  test "posts transfer using Transfer::Creator and is idempotent" do
    Current.set(family: @family) do
      date = Date.current
      res1 = EarlyPaymentService.call!(loan: @loan, amount: 100, mode: :shorten_term, date: date)
      assert res1.success?
      res2 = EarlyPaymentService.call!(loan: @loan, amount: 100, mode: :shorten_term, date: date)
      assert res2.success?
    end
  end
end
