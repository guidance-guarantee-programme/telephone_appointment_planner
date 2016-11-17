class AddAllDayToHolidays < ActiveRecord::Migration[5.0]
  def change
    add_column :holidays, :all_day, :boolean
    execute 'UPDATE holidays SET all_day = false'
    execute 'UPDATE holidays SET all_day = true WHERE user_id IS NULL'
    change_column_null :holidays, :all_day, null: false
  end
end
