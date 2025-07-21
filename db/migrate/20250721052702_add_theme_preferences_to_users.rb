class AddThemePreferencesToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :theme, :string, default: "system"
    add_column :users, :high_contrast_mode, :boolean, default: false
    add_column :users, :reduced_motion, :boolean, default: false
    add_column :users, :font_size, :string, default: "medium"
  end
end
