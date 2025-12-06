class AddTransferringPensionToToAppointments < ActiveRecord::Migration[8.0]
  def change
    add_column :appointments, :transferring_pension_to, :string, default: '', null: false
  end
end
