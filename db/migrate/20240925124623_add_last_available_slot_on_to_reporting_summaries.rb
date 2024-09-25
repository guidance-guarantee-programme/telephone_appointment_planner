class AddLastAvailableSlotOnToReportingSummaries < ActiveRecord::Migration[6.1]
  def change
    add_column :reporting_summaries, :last_available_slot_on, :date, nullable: true
  end
end
