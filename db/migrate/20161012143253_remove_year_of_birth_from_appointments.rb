class RemoveYearOfBirthFromAppointments < ActiveRecord::Migration[5.0]
  def change
    remove_column :appointments, :year_of_birth
  end
end
