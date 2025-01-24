class AddTsRangeGuiderIdIndexToAppointments < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      DROP INDEX IF EXISTS index_appointments_guider_id_tsrange_start_at_end_at;

      CREATE INDEX index_appointments_guider_id_tsrange_start_at_end_at
        ON appointments
        USING gist (guider_id, tsrange(start_at, end_at));
    SQL
  end

  def down
    execute 'DROP INDEX IF EXISTS index_appointments_guider_id_tsrange_start_at_end_at;'
  end
end
