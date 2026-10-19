class AddWaitlistOptInToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :waitlist_opt_in, :boolean, null: false, default: false
  end
end
