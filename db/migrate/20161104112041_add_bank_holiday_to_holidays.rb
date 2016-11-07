class AddBankHolidayToHolidays < ActiveRecord::Migration[5.0]
  def up
    add_column :holidays, :bank_holiday, :boolean
    execute 'UPDATE holidays SET bank_holiday = true WHERE user_id IS NULL'
    execute 'UPDATE holidays SET bank_holiday = false WHERE user_id IS NOT NULL'
    change_column_null :holidays, :bank_holiday, false
  end

  def down
    remove_column :holidays, :bank_holiday
  end
end
