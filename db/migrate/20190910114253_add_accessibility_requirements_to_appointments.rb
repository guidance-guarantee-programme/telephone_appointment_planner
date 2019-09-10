class AddAccessibilityRequirementsToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :accessibility_requirements, :boolean, default: false, null: false
  end
end
