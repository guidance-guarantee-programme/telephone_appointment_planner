class AddScheduleTypeToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :schedule_type, :string, default: User::PENSION_WISE_SCHEDULE_TYPE, null: false
  end
end
