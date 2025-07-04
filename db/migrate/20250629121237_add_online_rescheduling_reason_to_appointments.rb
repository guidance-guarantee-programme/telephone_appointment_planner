class AddOnlineReschedulingReasonToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :online_rescheduling_reason, :string, null: false, default: ''
    add_reference :appointments, :previous_guider
  end
end
