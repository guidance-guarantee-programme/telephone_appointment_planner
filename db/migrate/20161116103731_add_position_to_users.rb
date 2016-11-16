class AddPositionToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :position, :integer, null: false, default: 0
  end
end
