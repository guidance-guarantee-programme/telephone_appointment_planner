class CreateSlotRanges < ActiveRecord::Migration[5.0]
  def change
    create_table :slot_ranges do |t|
      t.integer :user_id, null: false
      t.datetime :from, null: false
      t.timestamps
    end
  end
end
