class AddReschedulingReasonToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :rescheduling_reason, :string, default: '', null: false
  end
end
