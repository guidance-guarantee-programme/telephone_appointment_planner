class RenameGroupsUsers < ActiveRecord::Migration[5.0]
  def change
    rename_table :groups_users, :group_assignments
  end
end
