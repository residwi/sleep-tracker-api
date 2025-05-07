class AddIndexesToSleepRecords < ActiveRecord::Migration[8.0]
  def change
    add_index :sleep_records, [ :user_id, :start_time ]
    add_index :sleep_records, :duration
    add_index :sleep_records, [ :user_id, :start_time, :duration ]
  end
end
