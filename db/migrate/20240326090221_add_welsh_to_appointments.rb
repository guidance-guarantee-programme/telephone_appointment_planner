class AddWelshToAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :welsh, :boolean, null: false, default: false
  end
end
