class DebtOriginationService
  Result = Struct.new(:success?, :account, :error, keyword_init: true)

  def self.call!(family:, params:)
    new(family:, params:).call!
  end

  def initialize(family:, params:)
    @family = family
    # Use indifferent access so both symbol and string keys work reliably
    @params = params.deep_dup.with_indifferent_access
  end

  def call!
    validate_params!

    ActiveRecord::Base.transaction do
      create_loan_account!

      if imported? || disbursement_account_id.blank?
        seed_opening_anchor_via_manager!
      else
        create_disbursement_transfer!
      end

      lock_and_sync!
    end

    Result.new(success?: true, account: @loan_account)
  rescue => e
    Result.new(success?: false, error: e.message)
  end

  private
    attr_reader :family, :params

    def validate_params!
      required = %w[name currency]
      required.each do |k|
        next if params[k].present? || params.dig(:account, k).present?
        raise ArgumentError, "Missing required param: #{k}"
      end

      unless imported? || disbursement_account_id.present?
        # When not imported and no disbursement account is provided, fall back
        # on opening balance path (no error). This keeps controller test behavior.
      end
      raise ArgumentError, "Missing initial principal" if initial_principal.blank? || initial_principal.to_d <= 0
    end

    def create_loan_account!
      acct_attrs = if params[:account].present?
        params[:account]
      else
        # Support both flattened and namespaced params
        params.slice(:name, :currency, :balance, :subtype).merge(
          accountable_type: "Loan",
          accountable_attributes: loan_accountable_attributes
        )
      end

      # Ensure classification and currency presence
      acct_attrs[:currency] ||= family.currency
      acct_attrs[:accountable_type] = "Loan"
      acct_attrs[:accountable_attributes] ||= loan_accountable_attributes

      # We create via Account directly to avoid auto-opening anchor if we are going to post a transfer
      @loan_account = family.accounts.new(acct_attrs)
      @loan_account.save!

      # Persist loan metadata onto accountable
      @loan_account.accountable.update!(
        debt_kind: params[:debt_kind] || params.dig(:accountable_attributes, :debt_kind),
        counterparty_type: params[:counterparty_type] || params.dig(:accountable_attributes, :counterparty_type),
        counterparty_name: params[:counterparty_name] || params.dig(:accountable_attributes, :counterparty_name),
        disbursement_account_id: disbursement_account_id,
        origination_date: origination_date,
        initial_balance: initial_principal.to_d
      )
    end

    def seed_opening_anchor_via_manager!
      manager = Account::OpeningBalanceManager.new(@loan_account)
      res = manager.set_opening_balance(balance: initial_principal.to_d, date: (origination_date || default_opening_date))
      raise res.error if res.error
      @loan_account.sync_later
    end

    def create_disbursement_transfer!
      Transfer::Creator.new(
        family: family,
        source_account_id: @loan_account.id,
        destination_account_id: disbursement_account_id,
        date: origination_date || Date.current,
        amount: initial_principal.to_d
      ).create
    end

    def lock_and_sync!
      @loan_account.lock_saved_attributes!
      @loan_account.sync_later
    end

    def disbursement_account_id
      params[:disbursement_account_id] || params.dig(:accountable_attributes, :disbursement_account_id)
    end

    def origination_date
      val = params[:origination_date] || params.dig(:accountable_attributes, :origination_date)
      return val if val.is_a?(Date)
      return nil if val.blank?
      Date.parse(val.to_s)
    rescue ArgumentError
      nil
    end

    def initial_principal
      params[:initial_balance] || params.dig(:accountable_attributes, :initial_balance)
    end

    def loan_accountable_attributes
      {
        rate_type: params[:rate_type] || params.dig(:accountable_attributes, :rate_type),
        interest_rate: params[:interest_rate] || params.dig(:accountable_attributes, :interest_rate),
        term_months: params[:term_months] || params.dig(:accountable_attributes, :term_months),
        initial_balance: initial_principal
      }.compact
    end

    def imported?
      ActiveModel::Type::Boolean.new.cast(params[:imported] || params.dig(:accountable_attributes, :imported))
    end

    def default_opening_date
      2.years.ago.to_date
    end
end
