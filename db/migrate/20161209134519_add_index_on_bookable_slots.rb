class AddIndexOnBookableSlots < ActiveRecord::Migration[5.0]
  def change
    add_index :bookable_slots, %i(start_at end_at)
  end
end
