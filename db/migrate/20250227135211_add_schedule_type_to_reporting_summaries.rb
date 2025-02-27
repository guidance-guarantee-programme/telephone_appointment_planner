class AddScheduleTypeToReportingSummaries < ActiveRecord::Migration[6.1]
  def change
    add_column :reporting_summaries, :schedule_type, :string, null: false, default: 'pension_wise'
  end
end
