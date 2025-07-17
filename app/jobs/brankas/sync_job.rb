module Brankas
  class SyncJob < ApplicationJob
    queue_as :default

    def perform
      Account.brankas.find_each { |account| sync_account(account) }
    end

    private

    def sync_account(account)
      client = Brankas::Client.new
      page   = 1

      loop do
        resp = client.transactions(page: page)
        resp.fetch("transactions").each { |txn| upsert_entry(account, txn) }
        break if resp.fetch("next_page").zero?
        page = resp.fetch("next_page")
      end
    end

    def upsert_entry(account, txn)
      account.entries.find_or_create_by!(external_id: txn["transaction_id"]) do |e|
        e.occurred_on      = Date.parse(txn.dig("additional_details", "created_at"))
        e.amount_cents     = txn.dig("amount", "value").to_i
        e.amount_currency  = txn.dig("amount", "currency")
        e.description      = txn.dig("additional_details", "description")
      end
    end
  end
end
