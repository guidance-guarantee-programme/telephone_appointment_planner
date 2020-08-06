class AddCasebookLocationIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :casebook_location_id, :integer
  end
end
