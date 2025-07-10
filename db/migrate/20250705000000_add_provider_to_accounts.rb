class AddProviderToAccounts < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:accounts, :provider)
      add_column :accounts, :provider, :string, null: false, default: "manual"
    end

    unless column_exists?(:accounts, :external_id)
      add_column :accounts, :external_id, :string
    end

    unless column_exists?(:accounts, :access_token_encrypted)
      add_column :accounts, :access_token_encrypted, :text
    end

    add_index :accounts, :provider unless index_exists?(:accounts, :provider)
    add_index :accounts, :external_id unless index_exists?(:accounts, :external_id)
  end
end
