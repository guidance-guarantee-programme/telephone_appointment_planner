class AddEmailConsentFormRequiredToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :email_consent_form_required, :boolean, default: false, null: false
  end
end
