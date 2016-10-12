class AddDateOfBirthToAppointments < ActiveRecord::Migration[5.0]
  def change
    add_column :appointments, :date_of_birth, :date
  end
end
