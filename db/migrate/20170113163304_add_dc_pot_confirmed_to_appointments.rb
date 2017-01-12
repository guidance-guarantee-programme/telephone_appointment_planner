class AddDcPotConfirmedToAppointments < ActiveRecord::Migration[5.0]
  def change
    add_column :appointments, :dc_pot_confirmed, :boolean, default: true, null: false
  end
end
