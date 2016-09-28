class CreateAvailableSlots < ActiveRecord::Migration[5.0]
  def change
    create_table :available_slots do |t|
      t.integer :user_id, null: false
      t.string :day, null: false
      t.string :start_at, null: false
      t.string :end_at, null: false
    end
  end
end
