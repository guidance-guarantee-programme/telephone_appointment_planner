class AddOtherReasonToAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :other_reason, :string, null: false, default: ''
  end
end
