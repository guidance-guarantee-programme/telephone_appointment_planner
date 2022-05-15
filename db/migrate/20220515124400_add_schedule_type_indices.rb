class AddScheduleTypeIndices < ActiveRecord::Migration[6.0]
  def change
    add_index :appointments, :schedule_type
    add_index :bookable_slots, :schedule_type

    add_index :users, :schedule_type
    add_index :users, :organisation_content_id
  end
end
