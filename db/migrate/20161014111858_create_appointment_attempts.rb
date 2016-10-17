class CreateAppointmentAttempts < ActiveRecord::Migration[5.0]
  def change
    create_table :appointment_attempts do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :date_of_birth, null: false
      t.boolean :defined_contribution_pot, null: false
      t.timestamps
    end
  end
end
