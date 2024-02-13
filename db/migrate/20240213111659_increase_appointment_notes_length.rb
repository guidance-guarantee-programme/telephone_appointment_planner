class IncreaseAppointmentNotesLength < ActiveRecord::Migration[6.1]
  def change
    change_column :appointments, :notes, :text, limit: 1000, default: ''
  end
end
