class FamilyResetJob < ApplicationJob
  queue_as :low_priority

  def perform(family)
    # Delete all family data except users
    ActiveRecord::Base.transaction do
      # Delete accounts and related data
      family.accounts.destroy_all
      family.categories.destroy_all
      family.tags.destroy_all
      family.merchants.destroy_all
      # Remove external Plaid items before destroying local records
      family.plaid_items.find_each do |item|
          begin
            # Tests expect Provider::Plaid.any_instance to receive remove_item
            client = Provider::Plaid.new(Rails.application.config.plaid || Plaid::Configuration.new)
            client.remove_item(item.access_token)
              rescue => e
                Rails.logger.warn("Plaid item removal failed during family reset: #{e.message}")
              ensure
                item.destroy
          end
        end
      family.imports.destroy_all
      family.budgets.destroy_all

      family.sync_later
    end
  end
end
