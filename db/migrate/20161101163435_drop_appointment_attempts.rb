class DropAppointmentAttempts < ActiveRecord::Migration[5.0]
  def change
    drop_table :appointment_attempts
  end
end
