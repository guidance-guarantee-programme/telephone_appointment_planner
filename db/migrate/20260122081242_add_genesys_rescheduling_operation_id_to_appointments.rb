class AddGenesysReschedulingOperationIdToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :genesys_rescheduling_operation_id, :string
    add_index :appointments, :genesys_rescheduling_operation_id
  end
end
