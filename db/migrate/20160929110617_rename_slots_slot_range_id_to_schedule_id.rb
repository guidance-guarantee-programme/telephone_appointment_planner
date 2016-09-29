class RenameSlotsSlotRangeIdToScheduleId < ActiveRecord::Migration[5.0]
  def change
    rename_column :slots, :slot_range_id, :schedule_id
  end
end
