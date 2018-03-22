class AddBatchProcessedAtToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :batch_processed_at, :datetime
  end
end
