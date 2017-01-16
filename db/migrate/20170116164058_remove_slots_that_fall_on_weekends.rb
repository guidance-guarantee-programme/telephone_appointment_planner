class RemoveSlotsThatFallOnWeekends < ActiveRecord::Migration[5.0]
  def change
    Slot.where(day_of_week: 0).delete_all
    Slot.where(day_of_week: 6).delete_all
  end
end
