class AddSmallPotsToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :small_pots, :boolean, default: false, null: false
  end
end
