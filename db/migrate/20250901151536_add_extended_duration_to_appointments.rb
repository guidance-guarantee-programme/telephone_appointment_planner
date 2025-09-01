class AddExtendedDurationToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :extended_duration, :boolean, null: false, default: false
  end
end
