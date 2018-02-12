class AllowNullOnUserPermissions < ActiveRecord::Migration[5.1]
  def change
    change_column_null :users, :permissions, true
  end
end
