class AddTimestampsToBookableSlots < ActiveRecord::Migration[5.0]
  class BookableSlot < ApplicationRecord; end

  def change
    add_timestamps :bookable_slots, null: true

    BookableSlot.update_all(
      created_at: Time.zone.now,
      updated_at: Time.zone.now
    )

    change_column_null :bookable_slots, :created_at, false
    change_column_null :bookable_slots, :updated_at, false
  end
end
