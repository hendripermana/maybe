class LoansController < ApplicationController
  include AccountableResource

  permitted_accountable_attributes(
    :id, :rate_type, :interest_rate, :term_months, :initial_balance,
    :debt_kind, :counterparty_type, :counterparty_name, :disbursement_account_id, :origination_date, :imported
  )

  # Override create to leverage DebtOriginationService for double-entry origination
  def create
    result = DebtOriginationService.call!(
      family: Current.family,
      params: account_params.to_h.deep_symbolize_keys
    )

    if result.success?
      redirect_to account_params[:return_to].presence || result.account, notice: t("accounts.create.success", type: "Loan")
    else
      @account = Current.family.accounts.build(
        currency: Current.family.currency,
        accountable: Loan.new
      )
      @error_message = result.error
      render :new, status: :unprocessable_entity
    end
  end

  # Prefill transfer form: source=cash-like account, destination=this loan
  def make_payment
    account = Current.family.accounts.find(params[:id])
    raise ActiveRecord::RecordNotFound unless account.accountable_type == "Loan"

    @transfer = Transfer.new
    @prefill = {
      from_account_id: default_cash_account_for(account)&.id,
      to_account_id: account.id,
      date: Date.current
    }

    render template: "loans/make_payment"
  end

  # Early payment modal (GET shows form, POST executes)
  def early_payment
    account = Current.family.accounts.find(params[:id])
    raise ActiveRecord::RecordNotFound unless account.accountable_type == "Loan"

    if request.get?
      @account = account
      render template: "loans/early_payment"
      return
    end

    amount = params.require(:early_payment).permit(:amount, :mode, :date, :cash_account_id)
    mode = (amount[:mode].presence || :shorten_term).to_sym
    date = amount[:date].present? ? Date.parse(amount[:date]) : Date.current

    # Allow overriding cash account
    cash_account = amount[:cash_account_id].present? ? Current.family.accounts.find(amount[:cash_account_id]) : nil

    service = EarlyPaymentService.new(loan: account.loan, amount: amount[:amount], mode: mode, date: date, family: Current.family)
    service.instance_variable_set(:@cash_account_id, cash_account&.id)
    result = service.call!

    if result.success?
      redirect_to account_path(account), notice: "Early payment recorded"
    else
      flash[:alert] = result.error || "Couldn't record early payment"
      redirect_to account_path(account)
    end
  rescue Money::ConversionError => e
    flash[:alert] = e.message
    redirect_to account_path(account)
  end

  # Reschedule modal (GET shows form, POST executes)
  def reschedule
    account = Current.family.accounts.find(params[:id])
    raise ActiveRecord::RecordNotFound unless account.accountable_type == "Loan"

    if request.get?
      @account = account
      render template: "loans/reschedule"
      return
    end

    attrs = params.require(:reschedule).permit(:new_term_months, :new_rate, :new_due_day, :effective_date, :reason)
    date = attrs[:effective_date].present? ? Date.parse(attrs[:effective_date]) : Date.current
    result = RescheduleService.call!(
      loan: account.loan,
      new_term_months: attrs[:new_term_months].presence,
      new_rate: attrs[:new_rate].presence,
      new_due_day: attrs[:new_due_day].presence,
      effective_date: date,
      reason: attrs[:reason],
      family: Current.family
    )

    if result.success?
      redirect_to account_path(account), notice: "Loan schedule updated"
    else
      flash[:alert] = result.error || "Couldn't update schedule"
      redirect_to account_path(account)
    end
  end

  private
    def default_cash_account_for(account)
      Current.family.accounts.where(accountable_type: "Depository").first || Current.family.accounts.assets.first
    end
end
