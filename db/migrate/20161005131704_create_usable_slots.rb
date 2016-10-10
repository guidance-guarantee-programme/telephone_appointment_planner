class CreateUsableSlots < ActiveRecord::Migration[5.0]
  def change
    create_table :usable_slots do |t|
      t.integer :user_id, null: false
      t.integer :appointment_id
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
    end
  end
end
