class BumpAppointmentsId < ActiveRecord::Migration[5.0]
  def change
    execute 'ALTER SEQUENCE appointments_id_seq RESTART 100000'
  end
end
