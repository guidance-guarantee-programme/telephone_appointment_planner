class AddSmarterSignpostedToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :smarter_signposted, :boolean, default: false, null: false
  end
end
