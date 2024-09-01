class AlterDuplicateAppointmentsIndex < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      DROP INDEX IF EXISTS unique_slot_guider_in_appointment;

      CREATE UNIQUE INDEX unique_slot_guider_in_appointment ON appointments (guider_id, start_at)
      WHERE status NOT IN (5, 6, 7, 8, 9) and start_at > '2024-01-01 00:00';
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX IF EXISTS unique_slot_guider_in_appointment;
    SQL
  end
end
