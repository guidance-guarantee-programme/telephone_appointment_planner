class AddWhoIsYourPensionProviderToAppointments < ActiveRecord::Migration[5.0]
  def change
    add_column :appointments, :who_is_your_pension_provider, :string, null: false, default: ''
  end
end
