class AddAgentIdToAppointments < ActiveRecord::Migration[5.0]
  def up
    execute 'DELETE FROM appointments'
    add_column :appointments, :agent_id, :integer, null: false, index: true
  end

  def down
    remove_column :appointments, :agent_id
  end
end
