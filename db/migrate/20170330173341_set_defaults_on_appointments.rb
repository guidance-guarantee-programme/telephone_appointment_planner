class SetDefaultsOnAppointments < ActiveRecord::Migration[5.0]
  def change
    change_column_default :appointments, :mobile, ''
    change_column_default :appointments, :notes, ''
  end
end
