class AddResolutionNotesToUserFeedbacks < ActiveRecord::Migration[7.2]
  def change
    add_column :user_feedbacks, :resolution_notes, :text
  end
end
