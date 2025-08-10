class Current < ActiveSupport::CurrentAttributes
  attribute :user_agent, :ip_address

  attribute :session, :family

  def family
    super || user&.family
  end

  def user
    impersonated_user || session&.user
  end

  def impersonated_user
    session&.active_impersonator_session&.impersonated
  end

  def true_user
    session&.user
  end
end
