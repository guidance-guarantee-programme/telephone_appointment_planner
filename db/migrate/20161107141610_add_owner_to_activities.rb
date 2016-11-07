class AddOwnerToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :owner_id, :integer, index: true
  end
end
