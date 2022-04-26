class AddNudgeFieldsToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :nudged, :boolean, default: false, null: false
    add_column :appointments, :nudge_confirmation, :string, default: '', null: false
    add_column :appointments, :nudge_eligibility_reason, :string, default: '', null: false
  end
end
