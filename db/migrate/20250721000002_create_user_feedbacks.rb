class CreateUserFeedbacks < ActiveRecord::Migration[7.2]
  def change
    create_table :user_feedbacks do |t|
      t.string :feedback_type, null: false
      t.text :message, null: false
      t.string :page, null: false
      t.references :user, type: :uuid, foreign_key: true
      t.string :browser
      t.string :theme
      t.boolean :resolved, default: false
      t.datetime :resolved_at
      t.uuid :resolved_by
      t.timestamps
    end

    add_index :user_feedbacks, :feedback_type
    add_index :user_feedbacks, :resolved
  end
end
