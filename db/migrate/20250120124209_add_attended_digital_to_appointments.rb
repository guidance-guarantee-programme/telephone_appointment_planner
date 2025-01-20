class AddAttendedDigitalToAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :attended_digital, :string
  end
end
