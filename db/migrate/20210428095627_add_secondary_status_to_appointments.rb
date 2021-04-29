class AddSecondaryStatusToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :secondary_status, :string, null: false, default: ''
  end
end
