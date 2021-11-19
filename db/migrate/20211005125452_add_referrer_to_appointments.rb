class AddReferrerToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :referrer, :string, null: false, default: ''
  end
end
