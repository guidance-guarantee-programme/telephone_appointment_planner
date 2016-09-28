class DropAvailableSlots < ActiveRecord::Migration[5.0]
  def change
    drop_table :available_slots
  end
end
