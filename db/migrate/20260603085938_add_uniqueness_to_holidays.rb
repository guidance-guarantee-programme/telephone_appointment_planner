class AddUniquenessToHolidays < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
      DROP INDEX IF EXISTS uniqueness_in_holidays;

      CREATE UNIQUE INDEX uniqueness_in_holidays
       ON holidays (title, start_at, end_at, user_id)
       WHERE start_at > '2026-06-03 00:00';
    SQL
  end

  def down
    execute 'DROP INDEX IF EXISTS uniqueness_in_holidays;'
  end
end
