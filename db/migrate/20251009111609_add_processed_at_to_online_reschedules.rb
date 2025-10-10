class AddProcessedAtToOnlineReschedules < ActiveRecord::Migration[8.0]
  def change
    add_column :online_reschedules, :processed_at, :datetime
  end
end
