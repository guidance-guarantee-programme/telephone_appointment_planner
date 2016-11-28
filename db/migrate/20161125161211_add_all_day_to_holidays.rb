class AddAllDayToHolidays < ActiveRecord::Migration[5.0]
  def up
    add_column :holidays, :all_day, :boolean, default: false, null: false
    Holiday.where(bank_holiday: true).update_all(all_day: true)
  end

  def down
    remove_column :holidays, :all_day
  end
end
