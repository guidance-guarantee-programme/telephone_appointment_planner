class AddMsTeamsCallToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :ms_teams_call, :boolean, default: false
  end
end
