class AddBslVideoToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :bsl_video, :boolean, default: false, null: false
  end
end
