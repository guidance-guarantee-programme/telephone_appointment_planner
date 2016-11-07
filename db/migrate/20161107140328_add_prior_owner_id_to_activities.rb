class AddPriorOwnerIdToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :prior_owner_id, :integer, index: true
  end
end
