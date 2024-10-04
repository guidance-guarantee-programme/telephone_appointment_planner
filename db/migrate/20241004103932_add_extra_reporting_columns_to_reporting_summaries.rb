class AddExtraReportingColumnsToReportingSummaries < ActiveRecord::Migration[6.1]
  def change
    add_column :reporting_summaries, :total_slots_available, :integer
    add_column :reporting_summaries, :total_slots_created, :integer
  end
end
