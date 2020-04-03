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
    create(:bookable_slot, start_at: Time.zone.parse('2018-04-26 09:00'))
    create(:bookable_slot, :tp, start_at: Time.zone.parse('2018-04-27 10:00'))
    create(:bookable_slot, :cas, start_at: Time.zone.parse('2018-04-28 11:00'))
    create(:bookable_slot, :ni, start_at: Time.zone.parse('2018-04-29 11:00'))
    create(:bookable_slot, :wallsend, start_at: Time.zone.parse('2018-04-29 11:00'))
    create(:bookable_slot, :lancs_west, start_at: Time.zone.parse('2018-04-29 11:00'))
  end

  def then_the_availability_is_summarised_correctly
    expect(ReportingSummary.find_by(organisation: 'CAS')).to have_attributes(
      four_week_availability: false,
      first_available_slot_on: nil
    )

    expect(ReportingSummary.find_by(organisation: 'Lancs West')).to have_attributes(
      four_week_availability: true,
      first_available_slot_on: '2018-04-29'.to_date
    )

    expect(ReportingSummary.find_by(organisation: 'Wallsend')).to have_attributes(
      four_week_availability: true,
      first_available_slot_on: '2018-04-29'.to_date
    )

    expect(ReportingSummary.find_by(organisation: 'NI')).to have_attributes(
      four_week_availability: true,
      first_available_slot_on: '2018-04-29'.to_date
    )

    expect(ReportingSummary.find_by(organisation: 'TP')).to have_attributes(
      four_week_availability: true,
      first_available_slot_on: '2018-04-27'.to_date
    )
  end

  def when_the_scheduled_report_runs
    ScheduledReportingSummary.new.call
  end

  def then_the_availability_is_summarised
    ReportingSummary.all.each do |entry|
      expect(entry).to have_attributes(
        four_week_availability: false,
        first_available_slot_on: nil
      )
    end
  end
end
