class AddDataSubjectDateOfBirthToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :data_subject_date_of_birth, :date
  end
end
