class RenameTagsToGroups < ActiveRecord::Migration[5.0]
  def change
    rename_table :tags, :groups
  end
end
