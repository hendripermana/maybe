class BrankasController < ApplicationController
  before_action :require_current_user

  # GET /brankas/link_url – returns the Brankas consent URL as JSON
  def link_url
    url = Brankas::Client.new.checkout(return_url: brankas_callback_url).fetch("redirect_url")
    render json: { url: url }
  end

  # GET /brankas/callback – Brankas redirects here with ?transaction_id=
  def callback
    tid = params[:transaction_id]
    raise ActiveRecord::RecordNotFound, "transaction_id missing" if tid.blank?

    data = Brankas::Client.new.transaction(tid)

    # Create a new account for this user if we haven't seen it before
    account = current_user.accounts.find_or_initialize_by(provider: :brankas, external_id: tid)
    account.name  ||= "#{data.dig("from", "account_name")} (Brankas)"
    account.save!

    redirect_to accounts_path, notice: "Bank account connected via Brankas!"
  end
end
