class AddTwoWeekAvailabilityToScheduledReportingSummaries < ActiveRecord::Migration[6.0]
  def change
    add_column :reporting_summaries, :two_week_availability, :boolean, null: false, default: false
  end
end
