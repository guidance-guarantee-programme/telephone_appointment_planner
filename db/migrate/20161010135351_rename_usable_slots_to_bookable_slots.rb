class RenameUsableSlotsToBookableSlots < ActiveRecord::Migration[5.0]
  def change
    rename_table :usable_slots, :bookable_slots
  end
end
