class BreakApartSlotsStartAndEnd < ActiveRecord::Migration[5.0]
  def up
    Slot.unscoped.destroy_all

    add_column :slots, :day_of_week, :integer
    add_column :slots, :start_hour, :integer
    add_column :slots, :start_minute, :integer
    add_column :slots, :end_hour, :integer
    add_column :slots, :end_minute, :integer

    remove_column :slots, :day
    remove_column :slots, :start_at
    remove_column :slots, :end_at
  end

  def down
    Slot.unscoped.destroy_all

    add_column :slots, :day, :string
    add_column :slots, :start_at, :string
    add_column :slots, :end_at, :string

    remove_column :slots, :day_of_week, :integer
    remove_column :slots, :start_hour, :integer
    remove_column :slots, :start_minute, :integer
    remove_column :slots, :end_hour, :integer
    remove_column :slots, :end_minute, :integer
  end
end
