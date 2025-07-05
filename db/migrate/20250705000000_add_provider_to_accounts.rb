class AddProviderToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :provider, :string, null: false, default: "manual"
    add_column :accounts, :external_id, :string
    add_column :accounts, :access_token_encrypted, :text

    add_index :accounts, :provider
    add_index :accounts, :external_id
  end
end
