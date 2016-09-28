class CreateSlots < ActiveRecord::Migration[5.0]
  def change
    create_table :slots do |t|
      t.integer :slot_range_id, null: false
      t.string :day, null: false
      t.string :start_at, null: false
      t.string :end_at, null: false
    end
  end
end
