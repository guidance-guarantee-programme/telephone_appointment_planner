class AddRescheduledAtToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :rescheduled_at, :datetime
  end
end
