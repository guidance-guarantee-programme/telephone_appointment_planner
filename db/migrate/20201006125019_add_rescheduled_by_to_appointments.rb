class AddRescheduledByToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :rescheduled_by, :integer
  end
end
