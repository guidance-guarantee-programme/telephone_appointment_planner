require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Scheduled reporting summary' do
  scenario 'When there is no availability' do
    when_the_scheduled_report_runs
    then_the_availability_is_summarised
  end

  scenario 'When there is PSG/due diligence availability' do
    travel_to '2018-04-23 10:00' do
      given_pension_wise_availability_in_the_booking_window
      and_psg_availability_in_the_booking_window
      when_the_scheduled_report_runs_for_psg
      then_the_correct_availability_is_summarised
    end
  end

  scenario 'When there is Pension Wise availability' do
    travel_to '2018-04-23 10:00' do
      given_pension_wise_availability_in_the_booking_window
      when_the_scheduled_report_runs
      then_the_availability_is_summarised_correctly
    end
  end

  def and_psg_availability_in_the_booking_window
    create(:bookable_slot, :due_diligence, start_at: Time.zone.parse('2018-05-01 09:00'))

    last_slot = create(:bookable_slot, :due_diligence, start_at: Time.zone.parse('2018-05-01 09:00'))
    create(
      :appointment,
      :due_diligence,
      guider: last_slot.guider,
      start_at: Time.zone.parse('2018-05-01 09:00')
    )
  end

  def when_the_scheduled_report_runs_for_psg
    ScheduledReportingSummary.new('due_diligence').call
  end

  def then_the_correct_availability_is_summarised
    # for PSG/DD it only runs for TPAS/Ops so just one record
    expect(ReportingSummary.count).to eq(1)

    expect(ReportingSummary.find_by(organisation: 'TPAS')).to have_attributes(
      schedule_type: 'due_diligence',
      two_week_availability: true,
      four_week_availability: true,
      first_available_slot_on: '2018-05-01'.to_date,
      last_available_slot_on: '2018-05-01'.to_date,
      total_slots_available: 1,
      total_slots_created: 2
    )
  end

  def given_pension_wise_availability_in_the_booking_window
    create(:bookable_slot, start_at: Time.zone.parse('2018-04-26 09:00'))
    create(:bookable_slot, :tp, start_at: Time.zone.parse('2018-04-27 10:00'))
    create(:bookable_slot, :cas, start_at: Time.zone.parse('2018-04-28 11:00'))
    create(:bookable_slot, :ni, start_at: Time.zone.parse('2018-04-29 11:00'))
    create(:bookable_slot, :north_tyneside, start_at: Time.zone.parse('2018-04-29 11:00'))
    create(:bookable_slot, :lancashire_west, start_at: Time.zone.parse('2018-04-29 11:00'))
    create(:bookable_slot, :lancashire_west, start_at: Time.zone.parse('2018-04-30 11:00'))
    create(:bookable_slot, :derbyshire_districts, start_at: Time.zone.parse('2018-05-12 11:00'))

    last_slot = create(:bookable_slot, :lancashire_west, start_at: Time.zone.parse('2018-05-01 13:00'))
    create(
      :appointment,
      organisation: :lancashire_west,
      guider: last_slot.guider,
      start_at: Time.zone.parse('2018-05-01 13:00')
    )
  end

  def then_the_availability_is_summarised_correctly
    expect(ReportingSummary.find_by(organisation: 'CAS')).to have_attributes(
      schedule_type: 'pension_wise',
      two_week_availability: true,
      four_week_availability: true,
      first_available_slot_on: '2018-04-28'.to_date,
      last_available_slot_on: '2018-04-28'.to_date,
      total_slots_available: 1,
      total_slots_created: 1
    )

    expect(ReportingSummary.find_by(organisation: 'Lancashire West')).to have_attributes(
      schedule_type: 'pension_wise',
      two_week_availability: true,
      four_week_availability: true,
      first_available_slot_on: '2018-04-29'.to_date,
      last_available_slot_on: '2018-04-30'.to_date,
      last_slot_on: '2018-05-01'.to_date,
      total_slots_available: 2,
      total_slots_created: 3
    )

    expect(ReportingSummary.find_by(organisation: 'North Tyneside')).to have_attributes(
      schedule_type: 'pension_wise',
      two_week_availability: true,
      four_week_availability: true,
      first_available_slot_on: '2018-04-29'.to_date
    )

    expect(ReportingSummary.find_by(organisation: 'NI')).to have_attributes(
      schedule_type: 'pension_wise',
      two_week_availability: true,
      four_week_availability: true,
      first_available_slot_on: '2018-04-29'.to_date
    )

    expect(ReportingSummary.find_by(organisation: 'TP')).to have_attributes(
      schedule_type: 'pension_wise',
      two_week_availability: true,
      four_week_availability: true,
      first_available_slot_on: '2018-04-27'.to_date
    )

    expect(ReportingSummary.find_by(organisation: 'Derbyshire Districts')).to have_attributes(
      schedule_type: 'pension_wise',
      two_week_availability: false,
      four_week_availability: true,
      first_available_slot_on: '2018-05-12'.to_date
    )
  end

  def when_the_scheduled_report_runs
    ScheduledReportingSummary.new('pension_wise').call
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
