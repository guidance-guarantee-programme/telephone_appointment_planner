class AddIndexesOnUsableSlots < ActiveRecord::Migration[5.0]
  def change
    add_index :usable_slots, :user_id
  end
end
