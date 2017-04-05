class DefaultAppointmentType < ActiveRecord::Migration[5.0]
  def change
    change_column_default :appointments, :type_of_appointment, ''
  end
end
