class AddIndexToHolidays < ActiveRecord::Migration[5.0]
  def change
    add_index :holidays, %i(start_at end_at)
  end
end
