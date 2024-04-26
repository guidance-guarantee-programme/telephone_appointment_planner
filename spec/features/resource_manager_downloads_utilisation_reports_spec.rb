require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Resource manager downloads utilisation reports' do
  scenario 'Non-TPAS user' do
    given_the_user_is_a_resource_manager(organisation: :tp) do
      when_they_view_the_report
      then_they_do_not_see_the_appointment_types
    end
  end

  scenario 'booked appointments are counted' do
    given_the_user_is_a_resource_manager do
      and_there_are_appointments
      when_they_download_utilisation_reports
      then_they_see_a_count_of_booked_appointments
    end
  end

  scenario 'cancelled appointments are counted' do
    given_the_user_is_a_resource_manager do
      and_there_are_cancelled_appointments
      when_they_download_utilisation_reports
      then_they_see_a_count_of_cancelled_appointments
    end
  end

  scenario 'date ranges must be provided' do
    given_the_user_is_a_resource_manager do
      when_they_attempt_to_download_reports_without_a_date_range
      then_they_see_a_validation_message
    end
  end

  scenario 'appointments outside date range are ignored' do
    given_the_user_is_a_resource_manager do
      and_there_are_appointments_outside_the_date_range
      when_they_download_utilisation_reports
      then_they_dont_see_the_appointments
    end
  end

  scenario 'cancelled appointments outside date range are ignored' do
    given_the_user_is_a_resource_manager do
      and_there_are_cancelled_appointments_outside_the_date_range
      when_they_download_utilisation_reports
      then_they_dont_see_the_cancelled_appointments
    end
  end

  scenario 'bookable slots are counted' do
    given_the_user_is_a_resource_manager do
      and_there_are_bookable_slots
      when_they_download_utilisation_reports
      then_they_see_the_bookable_slots
    end
  end

  scenario 'bookable slots obscured by appointments are counted' do
    given_the_user_is_a_resource_manager do
      and_there_are_bookable_slots_obscured_by_appointments
      when_they_download_utilisation_reports
      then_they_see_the_bookable_slots_obscured_by_appointments
    end
  end

  scenario 'bookable slots outside of date range are ignored' do
    given_the_user_is_a_resource_manager do
      and_there_are_bookable_slots_outside_the_date_range
      when_they_download_utilisation_reports
      then_they_do_not_see_the_bookable_slots
    end
  end

  scenario 'bookable slots obscured by bank holiday are counted as blocked' do
    given_the_user_is_a_resource_manager do
      and_there_are_bookable_slots_obscured_by_a_bank_holiday
      when_they_download_utilisation_reports
      then_they_see_the_blocked_bookable_slots
    end
  end

  scenario 'bookable slots obscured by user holidays are counted as blocked' do
    given_the_user_is_a_resource_manager do
      and_there_are_bookable_slots_obscured_by_a_user_holiday
      when_they_download_utilisation_reports
      then_they_see_the_blocked_bookable_slots
    end
  end

  def range_start
    Date.new(2016, 11, 7).beginning_of_day.to_date
  end

  def range_end
    Date.new(2016, 11, 9).beginning_of_day.to_date
  end

  def when_they_view_the_report
    @page = Pages::NewUtilisationReport.new.tap(&:load)
  end

  def then_they_do_not_see_the_appointment_types
    expect(@page).to have_no_pension_wise
    expect(@page).to have_no_due_diligence
  end

  def when_they_attempt_to_download_reports_without_a_date_range
    @page = Pages::NewUtilisationReport.new.tap(&:load)
    @page.pension_wise.set true
    @page.download.click
  end

  def then_they_see_a_validation_message
    expect(@page).to have_errors
  end

  def and_there_are_appointments
    guider = create(:guider)
    create(:appointment, guider:, start_at: range_start.at_midday + 1.day)
    create(:appointment, guider:, start_at: range_start.at_midday + 2.days)
  end

  def and_there_are_cancelled_appointments
    create(:appointment, status: :cancelled_by_customer_sms, start_at: range_start + 1.day)
    create(:appointment, status: :cancelled_by_pension_wise, start_at: range_start + 2.days)
    create(:appointment, :due_diligence, start_at: range_start.at_midday + 5.days)
  end

  def and_there_are_appointments_outside_the_date_range
    create(:appointment, start_at: range_start + 20.days)
  end

  def and_there_are_cancelled_appointments_outside_the_date_range
    create(:appointment, status: :cancelled_by_customer_sms, start_at: range_start + 10.days)
    create(:appointment, status: :cancelled_by_pension_wise, start_at: range_start + 11.days)
  end

  def and_there_are_bookable_slots
    create(:bookable_slot, start_at: range_start.at_midday)
    create(:bookable_slot, start_at: range_start.at_midday + 1.day)
    create(:bookable_slot, start_at: range_start.at_midday + 2.days)
  end

  def and_there_are_bookable_slots_obscured_by_appointments
    guider = create(:guider)

    appointment1 = create(:appointment, guider:, start_at: range_start.at_midday + 1.day)
    appointment2 = create(:appointment, guider:, start_at: range_start.at_midday + 2.days)

    create(:bookable_slot, start_at: appointment1.start_at)
    create(:bookable_slot, start_at: appointment2.start_at)
  end

  def and_there_are_bookable_slots_outside_the_date_range
    create(:bookable_slot, start_at: range_start.at_midday - 5.days)
    create(:bookable_slot, start_at: range_start.at_midday - 6.days)
  end

  def and_there_are_bookable_slots_obscured_by_a_bank_holiday
    holiday = create(:bank_holiday, start_at: range_start + 1.day, end_at: range_start + 4.days)
    create(:bookable_slot, start_at: holiday.start_at + 1.hour)
    create(:bookable_slot, start_at: holiday.start_at + 1.hour)
  end

  def and_there_are_bookable_slots_obscured_by_a_user_holiday
    guider = create(:guider)
    holiday = create(:holiday, user: guider, start_at: range_start + 1.day, end_at: range_start + 2.days)
    create(:bookable_slot, guider:, start_at: holiday.start_at + 1.hour)
    create(:bookable_slot, guider:, start_at: holiday.start_at + 5.hours)
  end

  def when_they_download_utilisation_reports
    date_range = [
      I18n.l(range_start, format: :date_range_picker),
      I18n.l(range_end, format: :date_range_picker)
    ].join(' - ')

    @page = Pages::NewUtilisationReport.new.tap(&:load)
    @page.date_range.set date_range
    @page.pension_wise.set true
    @page.download.click
  end

  def then_they_see_a_count_of_booked_appointments
    expect_csv(
      [
        %w[2016-11-07 0 0 0 0],
        %w[2016-11-08 1 0 0 0],
        %w[2016-11-09 1 0 0 0]
      ]
    )
  end

  def then_they_see_a_count_of_cancelled_appointments
    expect_csv(
      [
        %w[2016-11-07 0 0 0 0],
        %w[2016-11-08 0 0 0 1],
        %w[2016-11-09 0 0 0 1]
      ]
    )
  end

  def then_they_dont_see_the_appointments
    expect_csv(
      [
        %w[2016-11-07 0 0 0 0],
        %w[2016-11-08 0 0 0 0],
        %w[2016-11-09 0 0 0 0]
      ]
    )
  end

  def then_they_dont_see_the_cancelled_appointments
    expect_csv(
      [
        %w[2016-11-07 0 0 0 0],
        %w[2016-11-08 0 0 0 0],
        %w[2016-11-09 0 0 0 0]
      ]
    )
  end

  def then_they_see_the_bookable_slots
    expect_csv(
      [
        %w[2016-11-07 0 1 0 0],
        %w[2016-11-08 0 1 0 0],
        %w[2016-11-09 0 1 0 0]
      ]
    )
  end

  def then_they_see_the_bookable_slots_obscured_by_appointments
    expect_csv(
      [
        %w[2016-11-07 0 0 0 0],
        %w[2016-11-08 1 1 0 0],
        %w[2016-11-09 1 1 0 0]
      ]
    )
  end

  def then_they_do_not_see_the_bookable_slots
    expect_csv(
      [
        %w[2016-11-07 0 0 0 0],
        %w[2016-11-08 0 0 0 0],
        %w[2016-11-09 0 0 0 0]
      ]
    )
  end

  def then_they_see_the_blocked_bookable_slots
    expect_csv(
      [
        %w[2016-11-07 0 0 0 0],
        %w[2016-11-08 0 0 2 0],
        %w[2016-11-09 0 0 0 0]
      ]
    )
  end

  def expect_csv(csv)
    @page = Pages::ReportCsv.new

    expected_file_name = "utilisation-report-#{range_start.to_time.to_i}-#{range_end.to_time.to_i}.csv"
    expect(@page.content_disposition).to eq "attachment; filename=#{expected_file_name}"

    expected_csv = [
      %i[date booked_appointments bookable_slots blocked_slots cancelled_appointments]
    ] + csv
    expect(@page.csv).to eq(expected_csv)
  end
end
# rubocop:enable Metrics/BlockLength
