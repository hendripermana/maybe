# Creates a Loan account using the existing Account.create_and_sync pathway
# and applies Loan-specific attributes (interest_rate, term_months, etc.).
class DebtOriginationService
  Result = Struct.new(:success?, :account, :error, keyword_init: true)

  def self.call!(family:, params:)
    new(family:, params:).call!
  end

  def initialize(family:, params:)
    @family = family
    @params = params
  end

  def call!
    account = nil
    Account.transaction do
      base_attrs = @params.slice(:name, :balance, :currency, :accountable_type)
      acc_attrs = @params[:accountable_attributes] || {}

      account = @family.accounts.create_and_sync(
        base_attrs.merge(
          accountable_attributes: acc_attrs.symbolize_keys
        )
      )
    end

    Result.new(success?: true, account: account)
  rescue => e
    Result.new(success?: false, error: e.message)
  end
end
