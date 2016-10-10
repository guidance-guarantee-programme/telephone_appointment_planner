class RenameUserIdToGuiderId < ActiveRecord::Migration[5.0]
  def change
    rename_column :usable_slots, :user_id, :guider_id
    rename_column :appointments, :user_id, :guider_id
  end
end
