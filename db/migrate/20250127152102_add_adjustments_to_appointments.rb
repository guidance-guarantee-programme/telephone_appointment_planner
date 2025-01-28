class AddAdjustmentsToAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :adjustments, :string, null: false, default: ''
  end
end
