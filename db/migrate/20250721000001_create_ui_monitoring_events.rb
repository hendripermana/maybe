class CreateUiMonitoringEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :ui_monitoring_events do |t|
      t.string :event_type, null: false
      t.jsonb :data
      t.references :user, type: :uuid, foreign_key: true
      t.string :session_id
      t.string :user_agent
      t.string :ip_address
      t.timestamps
    end

    add_index :ui_monitoring_events, :event_type
    add_index :ui_monitoring_events, :created_at
    add_index :ui_monitoring_events, :session_id
  end
end
