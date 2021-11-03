class AddIndexToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_index :appointments, :guider_id, using: :btree
    add_index :appointments, %i(start_at end_at guider_id), using: :btree
  end
end
