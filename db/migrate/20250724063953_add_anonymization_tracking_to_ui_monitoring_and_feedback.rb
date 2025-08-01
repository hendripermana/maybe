class AddAnonymizationTrackingToUiMonitoringAndFeedback < ActiveRecord::Migration[7.2]
  def change
    # Add anonymization tracking to UI monitoring events
    add_column :ui_monitoring_events, :data_anonymized, :boolean, default: false, null: false
    add_column :ui_monitoring_events, :anonymized_at, :datetime
    add_index :ui_monitoring_events, :data_anonymized

    # Add anonymization tracking to user feedback
    add_column :user_feedbacks, :data_anonymized, :boolean, default: false, null: false
    add_column :user_feedbacks, :anonymized_at, :datetime
    add_index :user_feedbacks, :data_anonymized
  end
end
