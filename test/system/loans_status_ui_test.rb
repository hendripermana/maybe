require "application_system_test_case"

class LoansStatusUiTest < ApplicationSystemTestCase
  test "loan status chip appears on account index for loan" do
    sign_in users(:family_admin)
    visit accounts_path
    assert_text "Mortgage Loan"
    assert_selector("span", text: /Active|In grace|Overdue|Paid off/i)
  end
end
