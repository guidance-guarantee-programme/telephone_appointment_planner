require 'rails_helper'

# rubocop:disable Metrics/BlockLength
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
    create(:bookable_slot, :north_tyneside, start_at: Time.zone.parse('2018-04-29 11:00'))
    create(:bookable_slot, :lancashire_west, start_at: Time.zone.parse('2018-04-29 11:00'))
    create(:bookable_slot, :derbyshire_districts, start_at: Time.zone.parse('2018-05-12 11:00'))
  end

  def then_the_availability_is_summarised_correctly
    expect(ReportingSummary.find_by(organisation: 'CAS')).to have_attributes(
      two_week_availability: true,
      four_week_availability: true,
      first_available_slot_on: '2018-04-28'.to_date
    )

    expect(ReportingSummary.find_by(organisation: 'Lancashire West')).to have_attributes(
      two_week_availability: true,
      four_week_availability: true,
      first_available_slot_on: '2018-04-29'.to_date
    )

    expect(ReportingSummary.find_by(organisation: 'North Tyneside')).to have_attributes(
      two_week_availability: true,
      four_week_availability: true,
      first_available_slot_on: '2018-04-29'.to_date
    )

    expect(ReportingSummary.find_by(organisation: 'NI')).to have_attributes(
      two_week_availability: true,
      four_week_availability: true,
      first_available_slot_on: '2018-04-29'.to_date
    )

    expect(ReportingSummary.find_by(organisation: 'TP')).to have_attributes(
      two_week_availability: true,
      four_week_availability: true,
      first_available_slot_on: '2018-04-27'.to_date
    )

    expect(ReportingSummary.find_by(organisation: 'Derbyshire Districts')).to have_attributes(
      two_week_availability: false,
      four_week_availability: true,
      first_available_slot_on: '2018-05-12'.to_date
    )
  end

  def when_the_scheduled_report_runs
    ScheduledReportingSummary.new.call
  end

  def then_the_availability_is_summarised
    ReportingSummary.all.find_each do |entry|
      expect(entry).to have_attributes(
        two_week_availability: false,
        four_week_availability: false,
        first_available_slot_on: nil
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
