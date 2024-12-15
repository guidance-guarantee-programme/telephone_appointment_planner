class AddAppointmentsIndexForSlotsOptimisations < ActiveRecord::Migration[6.1]
  def change
    add_index :appointments,
      :guider_id,
      name: 'index_appointments_guider_schedule_status',
      where: "schedule_type::text = 'pension_wise'::text AND status <> ALL('{6,7,8,9}'::integer[]);"
  end
end
