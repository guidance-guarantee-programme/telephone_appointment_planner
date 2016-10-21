class ChangeUserPermissionsToJson < ActiveRecord::Migration[5.0]
  def up
    remove_column :users, :permissions
    add_column :users, :permissions, :jsonb, null: false, default: '[]'
    add_index :users, :permissions, using: :gin
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
