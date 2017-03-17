class AddResolutionColumnsToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :resolved_at, :datetime
    add_column :activities, :resolver_id, :integer
  end
end
