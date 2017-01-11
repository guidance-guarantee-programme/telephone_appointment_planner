class AddStartAtEndAtIndexOnAppointments < ActiveRecord::Migration[5.0]
  def change
    add_index :appointments, %i(start_at end_at)
  end
end
