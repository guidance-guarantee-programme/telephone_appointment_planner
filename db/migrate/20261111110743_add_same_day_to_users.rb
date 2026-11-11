class AddSameDayToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :same_day, :boolean, default: false, null: false
  end
end
