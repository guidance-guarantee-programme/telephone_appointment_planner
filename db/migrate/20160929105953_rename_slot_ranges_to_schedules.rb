class RenameSlotRangesToSchedules < ActiveRecord::Migration[5.0]
  def change
    rename_table :slot_ranges, :schedules
  end
end
