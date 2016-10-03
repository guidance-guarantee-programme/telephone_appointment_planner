class RenameSchedulesFromToStartAt < ActiveRecord::Migration[5.0]
  def change
    rename_column :schedules, :from, :start_at
  end
end
