class AddCountryCodeToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :country_code, :string, null: false, default: 'GB'
  end
end
