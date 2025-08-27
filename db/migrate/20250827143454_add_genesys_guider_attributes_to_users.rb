class AddGenesysGuiderAttributesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :genesys_agent_id, :string
    add_column :users, :genesys_management_unit_id, :string
  end
end
