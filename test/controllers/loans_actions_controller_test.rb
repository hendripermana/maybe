require "test_helper"

class LoansActionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:family_admin)
    @family = families(:dylan_family)
    @cash = accounts(:depository)
    @loan = accounts(:loan)
  end

  test "early payment posts and is idempotent" do
    assert_difference -> { Transfer.count }, +1 do
      post early_payment_loan_path(@loan), params: { early_payment: { amount: 10, mode: :shorten_term, date: Date.current, cash_account_id: @cash.id } }
      assert_redirected_to account_path(@loan)
    end

    assert_no_difference -> { Transfer.count } do
      post early_payment_loan_path(@loan), params: { early_payment: { amount: 10, mode: :shorten_term, date: Date.current, cash_account_id: @cash.id } }
      assert_redirected_to account_path(@loan)
    end
  end

  test "reschedule updates schedule and is idempotent by reason key" do
    post reschedule_loan_path(@loan), params: { reschedule: { new_term_months: 240, effective_date: Date.current, reason: "test" } }
    assert_redirected_to account_path(@loan)

    assert_no_changes -> { @loan.reload.loan.schedule_version } do
      post reschedule_loan_path(@loan), params: { reschedule: { new_term_months: 240, effective_date: Date.current, reason: "test" } }
      assert_redirected_to account_path(@loan)
    end
  end
end
