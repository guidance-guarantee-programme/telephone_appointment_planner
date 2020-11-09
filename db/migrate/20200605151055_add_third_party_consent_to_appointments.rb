class AddThirdPartyConsentToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :third_party_booking, :boolean, default: false, null: false
    add_column :appointments, :third_party_consent, :boolean
  end
end
