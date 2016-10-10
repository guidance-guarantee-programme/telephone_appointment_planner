class RemoveAppointmentIdFromUsableSlots < ActiveRecord::Migration[5.0]
  def change
    remove_column :usable_slots, :appointment_id
  end
end
