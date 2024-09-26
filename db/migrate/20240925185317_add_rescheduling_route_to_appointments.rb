class AddReschedulingRouteToAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :rescheduling_route, :string, null: false, default: ''
  end
end
