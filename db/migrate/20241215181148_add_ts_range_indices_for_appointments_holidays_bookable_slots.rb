class AddTsRangeIndicesForAppointmentsHolidaysBookableSlots < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      DROP INDEX IF EXISTS index_bookable_slots_tsrange_start_at_end_at;
      DROP INDEX IF EXISTS index_appointments_tsrange_start_at_end_at;
      DROP INDEX IF EXISTS index_holidays_tsrange_start_at_end_at;
      DROP INDEX IF EXISTS index_appointments_guider_start_schedule_status;
      DROP INDEX IF EXISTS index_holidays_userid_tsrange;

      CREATE INDEX index_bookable_slots_tsrange_start_at_end_at ON bookable_slots USING gist (tsrange(start_at, end_at));
      CREATE INDEX index_appointments_tsrange_start_at_end_at ON appointments USING gist (tsrange(start_at, end_at));
      CREATE INDEX index_holidays_tsrange_start_at_end_at ON holidays USING gist (tsrange(start_at, end_at));
      CREATE INDEX index_appointments_guider_start_schedule_status on appointments USING btree (guider_id, start_at) WHERE schedule_type::text = 'pension_wise'::text AND (status <> ALL ('{6,7,8,9}'::integer[]));
      CREATE INDEX index_holidays_userid_tsrange on holidays USING gist (user_id, tsrange(start_at, end_at));
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX IF EXISTS index_bookable_slots_tsrange_start_at_end_at;
      DROP INDEX IF EXISTS index_appointments_tsrange_start_at_end_at;
      DROP INDEX IF EXISTS index_holidays_tsrange_start_at_end_at;
      DROP INDEX IF EXISTS index_appointments_guider_start_schedule_status;
      DROP INDEX IF EXISTS index_holidays_userid_tsrange;
    SQL
  end
end
