class AddTimestampsToAppointments < ActiveRecord::Migration[5.0]
  def change
    add_timestamps :appointments, null: true
    execute 'UPDATE appointments SET created_at = NOW(), updated_at = NOW()'
    change_column_null :appointments, :created_at, false
    change_column_null :appointments, :updated_at, false
  end
end
