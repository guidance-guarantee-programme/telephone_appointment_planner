class AddCancelledViaToAppointments < ActiveRecord::Migration[6.1]
  def change
    add_column :appointments, :cancelled_via, :string, null: false, default: ''
  end
end
