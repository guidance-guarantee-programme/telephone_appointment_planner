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
    create(:bookable_slot, :cita_wallsend, start_at: Time.zone.parse('2018-04-29 11:00'))
    create(:bookable_slot, :cita_lancs_west, start_at: Time.zone.parse('2018-04-29 11:00'))
  end

  def then_the_availability_is_summarised_correctly
    expect(ReportingSummary.first).to have_attributes(
      organisation: 'CAS',
      four_week_availability: true,
      first_available_slot_on: '2018-04-28'.to_date
    )

    expect(ReportingSummary.second).to have_attributes(
      organisation: 'CITA Lancs West',
      four_week_availability: true,
      first_available_slot_on: '2018-04-29'.to_date
    )

    expect(ReportingSummary.third).to have_attributes(
      organisation: 'CITA Wallsend',
      four_week_availability: true,
      first_available_slot_on: '2018-04-29'.to_date
    )

    expect(ReportingSummary.fourth).to have_attributes(
      organisation: 'NI',
      four_week_availability: true,
      first_available_slot_on: '2018-04-29'.to_date
    )

    expect(ReportingSummary.fifth).to have_attributes(
      organisation: 'TP',
      four_week_availability: true,
      first_available_slot_on: '2018-04-27'.to_date
    )
  end

  def when_the_scheduled_report_runs
    ScheduledReportingSummary.new.call
  end

  def then_the_availability_is_summarised
    expect(ReportingSummary.count).to eq(6)

    ReportingSummary.all.each do |entry|
      expect(entry).to have_attributes(
        organisation: a_string_matching(/TPAS|CAS|TP|NI|CITA Wallsend|CITA Lancs West/),
        four_week_availability: false,
        first_available_slot_on: nil
      )
    end
  end
end
