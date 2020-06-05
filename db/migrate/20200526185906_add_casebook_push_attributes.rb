class AddCasebookPushAttributes < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :casebook_guider_id, :integer, unique: true
    add_column :appointments, :casebook_appointment_id, :integer, unique: true
  end
end
