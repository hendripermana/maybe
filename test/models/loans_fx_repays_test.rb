require "test_helper"

class LoansFxRepaysTest < ActiveSupport::TestCase
  test "cross currency early payment uses historical rate and raises when missing" do
    family = families(:dylan_family)
    usd_loan = accounts(:loan)
    idr_cash = family.accounts.create!(name: "IDR Wallet", currency: "IDR", balance: 100_000, accountable: Depository.new)

    # Stub provider to return nil to force error
    ExchangeRate.expects(:find_or_fetch_rate).returns(nil)

    service = EarlyPaymentService.new(loan: usd_loan.loan, amount: 100, mode: :shorten_term, date: Date.current, family: family)
    service.instance_variable_set(:@cash_account_id, idr_cash.id)

    result = service.call!
    assert_not result.success?
    assert_match(/ConversionError|Couldn't find exchange rate/i, result.error)
  end
end
