class AddScheduleFieldsToLoans < ActiveRecord::Migration[7.2]
  def up
    change_table :loans do |t|
      t.integer  :due_day
      t.integer  :grace_days, default: 5, null: false
      t.integer  :schedule_version, default: 1, null: false
      t.datetime :rescheduled_at
      t.text     :reschedule_reason
    end

    # Backfill due_day from origination_date.day where present (clamped at DB level by day extraction)
    execute <<~SQL.squish
      UPDATE loans
      SET due_day = EXTRACT(DAY FROM origination_date)::int
      WHERE origination_date IS NOT NULL AND due_day IS NULL
    SQL
  end

  def down
    change_table :loans do |t|
      t.remove :due_day, :grace_days, :schedule_version, :rescheduled_at, :reschedule_reason
    end
  end
end
