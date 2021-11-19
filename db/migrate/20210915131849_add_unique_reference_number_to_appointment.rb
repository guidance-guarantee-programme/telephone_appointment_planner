class AddUniqueReferenceNumberToAppointment < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :unique_reference_number, :string, unique: true, default: '', null: false
  end
end
