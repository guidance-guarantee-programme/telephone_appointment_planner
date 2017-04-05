class AddTypeOfAppointmentToAppointments < ActiveRecord::Migration[5.0]
  def change
    add_column :appointments, :type_of_appointment, :string, null: false, default: 'standard'
  end
end
