class AddScheduleTypeToUsersAndBookableSlots < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :schedule_type, :string, default: User::PENSION_WISE_SCHEDULE_TYPE, null: false
    add_column :bookable_slots, :schedule_type, :string, default: User::PENSION_WISE_SCHEDULE_TYPE, null: false
  end
end
