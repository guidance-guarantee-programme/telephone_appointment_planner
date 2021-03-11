class AddUniqueCheckForAppointments < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE UNIQUE INDEX unique_slot_guider_in_appointment ON appointments (guider_id, start_at)
      WHERE status NOT IN (6, 7, 8);
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX IF EXISTS unique_slot_guider_in_appointment;
    SQL
  end
end
