class AddLloydsSignpostedToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :lloyds_signposted, :boolean, null: false, default: false
  end
end
