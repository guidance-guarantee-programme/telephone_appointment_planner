class AddPreviousStartAtToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :previous_start_at, :datetime, null: true
  end
end
