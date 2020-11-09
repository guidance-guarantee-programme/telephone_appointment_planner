class AddEmailConsentToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :email_consent, :string, null: false, default: ''
  end
end
