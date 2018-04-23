require 'rails_helper'

RSpec.feature 'Scheduled reporting summary' do
  scenario 'When there is no availability' do
    when_the_scheduled_report_runs
    then_the_availability_is_summarised
  end

  scenario 'When there is availability' do
    travel_to '2018-04-23 10:00' do
      given_availability_in_the_booking_window
      when_the_scheduled_report_runs
      then_the_availability_is_summarised_correctly
    end
  end

  def given_availability_in_the_booking_window
    @slot = create(:bookable_slot, start_at: Time.zone.parse('2018-04-26 09:00'))
  end

  def then_the_availability_is_summarised_correctly
    expect(ReportingSummary.count).to eq(1)

    expect(ReportingSummary.first).to have_attributes(
      organisation: 'TPAS',
      four_week_availability: true,
      first_available_slot_on: '2018-04-26'.to_date
    )
  end

  def when_the_scheduled_report_runs
    ScheduledReportingSummary.new.call
  end

  def then_the_availability_is_summarised
    expect(ReportingSummary.count).to eq(1)

    expect(ReportingSummary.first).to have_attributes(
      organisation: 'TPAS',
      four_week_availability: false,
      first_available_slot_on: nil
    )
  end
end
