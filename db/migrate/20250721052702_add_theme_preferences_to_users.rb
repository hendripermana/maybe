class AddThemePreferencesToUsers < ActiveRecord::Migration[7.2]
  def change
    # Skip adding theme column if it already exists
    unless column_exists?(:users, :theme)
      add_column :users, :theme, :string, default: "system"
    end
    
    add_column :users, :high_contrast_mode, :boolean, default: false unless column_exists?(:users, :high_contrast_mode)
    add_column :users, :reduced_motion, :boolean, default: false unless column_exists?(:users, :reduced_motion)
    add_column :users, :font_size, :string, default: "medium" unless column_exists?(:users, :font_size)
  end
end
