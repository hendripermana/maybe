class Settings::HostingsController < ApplicationController
  layout "settings"

  guard_feature unless: -> { self_hosted? }

  before_action :ensure_admin, only: :clear_cache

  def show
    exchange_rates_provider = Provider::Registry.get_provider(:exchange_rates_api)
    @exchange_rates_usage = exchange_rates_provider&.usage

    alpha_vantage_provider = Provider::Registry.get_provider(:alpha_vantage)
    @alpha_vantage_usage = alpha_vantage_provider&.usage
  end

  def update
    if hosting_params.key?(:require_invite_for_signup)
      Setting.require_invite_for_signup = hosting_params[:require_invite_for_signup]
    end

    if hosting_params.key?(:require_email_confirmation)
      Setting.require_email_confirmation = hosting_params[:require_email_confirmation]
    end

    if hosting_params.key?(:exchange_rates_api_key)
      Setting.exchange_rates_api_key = hosting_params[:exchange_rates_api_key]
    end

    if hosting_params.key?(:alpha_vantage_api_key)
      Setting.alpha_vantage_api_key = hosting_params[:alpha_vantage_api_key]
    end

    redirect_to settings_hosting_path, notice: t(".success")
  rescue ActiveRecord::RecordInvalid => error
    flash.now[:alert] = t(".failure")
    render :show, status: :unprocessable_entity
  end

  def clear_cache
    DataCacheClearJob.perform_later(Current.family)
    redirect_to settings_hosting_path, notice: t(".cache_cleared")
  end

  private
    def hosting_params
      params.require(:setting).permit(:require_invite_for_signup, :require_email_confirmation, :exchange_rates_api_key, :alpha_vantage_api_key)
    end

    def ensure_admin
      redirect_to settings_hosting_path, alert: t(".not_authorized") unless Current.user.admin?
    end
end
