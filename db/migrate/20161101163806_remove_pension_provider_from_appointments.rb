class RemovePensionProviderFromAppointments < ActiveRecord::Migration[5.0]
  def change
    remove_column :appointments, :who_is_your_pension_provider
  end
end
