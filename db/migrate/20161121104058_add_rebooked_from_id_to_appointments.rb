class AddRebookedFromIdToAppointments < ActiveRecord::Migration[5.0]
  def change
    add_column :appointments, :rebooked_from_id, :integer
  end
end
