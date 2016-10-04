class BreakApartSlotsStartAndEnd < ActiveRecord::Migration[5.0]
  def change
    add_column :slots, :day_of_week, :integer
    add_column :slots, :start_hour, :integer
    add_column :slots, :start_minute, :integer
    add_column :slots, :end_hour, :integer
    add_column :slots, :end_minute, :integer

    Slot.all.each do |slot|
      slot.day_of_week = Date::DAYNAMES.index(slot.day)
      slot.start_hour, slot.start_minute = slot.start_at.split(':')
      slot.end_hour, slot.end_minute = slot.end_at.split(':')
      slot.save!
    end

    change_column_null :slots, :day_of_week, false
    change_column_null :slots, :start_hour, false
    change_column_null :slots, :start_minute, false
    change_column_null :slots, :end_hour, false
    change_column_null :slots, :end_minute, false

    remove_column :slots, :day
    remove_column :slots, :start_at
    remove_column :slots, :end_at
  end
end
