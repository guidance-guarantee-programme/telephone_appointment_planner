class AddStartAtIndexOnAppointments < ActiveRecord::Migration[5.0]
  def change
    add_index :appointments, :start_at
  end
end
