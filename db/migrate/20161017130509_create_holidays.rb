class CreateHolidays < ActiveRecord::Migration[5.0]
  def change
    create_table :holidays do |t|
      t.integer  :user_id, index: true
      t.string   :title
      t.datetime :start_at
      t.datetime :end_at
      t.timestamps
    end
  end
end
