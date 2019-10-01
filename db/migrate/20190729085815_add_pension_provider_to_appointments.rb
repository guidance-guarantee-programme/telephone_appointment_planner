class AddPensionProviderToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :pension_provider, :string, null: false, default: ''
  end
end
