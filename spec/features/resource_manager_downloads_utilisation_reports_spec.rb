require 'rails_helper'

RSpec.feature 'Resource manager downloads utilisation reports' do
  scenario 'in a date range' do
    given_the_user_is_a_resource_manager do
      travel_to now do
        and_there_are_data
        when_they_download_utilisation_reports_for_a_date_range
        then_they_get_utilisation_reports_in_that_range
      end
    end
  end

  let(:now) do
    # Tuesday
    Date.new(2016, 11, 1)
  end

  let(:start_at) do
    BusinessDays.from_now(10).beginning_of_day.to_date
  end

  let(:end_at) do
    BusinessDays.from_now(30).beginning_of_day.to_date
  end

  let(:date_range) do
    [
      I18n.l(start_at, format: :date_range_picker),
      I18n.l(end_at, format: :date_range_picker)
    ].join(' - ')
  end

  def and_there_are_data
    guider = create(:guider)

    # booked appointments
    appointments = [
      create(:appointment, guider: guider, start_at: start_at.at_midday + 1.day),
      create(:appointment, guider: guider, start_at: start_at.at_midday + 2.days)
    ]

    # cancelled appointments
    create(:appointment, status: :cancelled_by_customer, start_at: start_at + 1.day)
    create(:appointment, status: :cancelled_by_pension_wise, start_at: start_at + 2.days)

    # ignored appointment
    create(:appointment, start_at: now + 2.days)

    # ignored cancelled appointment
    create(:appointment, status: :cancelled_by_customer, start_at: now + 2.days)
    create(:appointment, status: :cancelled_by_pension_wise, start_at: now + 2.days)

    # bookable slots
    create(:bookable_slot, start_at: start_at.at_midday + 5.days)
    create(:bookable_slot, start_at: start_at.at_midday + 6.days)
    create(:bookable_slot, start_at: start_at.at_midday + 7.days)

    # bookable slot (obsured by appointment, which is still counted)
    create(:bookable_slot, start_at: appointments.first.start_at)

    # ignored slot (out of date range)
    create(:bookable_slot, start_at: start_at.at_midday - 5.days)

    # blocked slot (obsured by global holiday)
    holiday = create(:bank_holiday, start_at: start_at + 8.days, end_at: start_at + 9.days)
    create(:bookable_slot, start_at: holiday.start_at + 1.hour)
    # blocked slot (obscured by user holiday)
    guider = create(:guider)
    holiday = create(:holiday, user: guider, start_at: start_at + 10.days, end_at: start_at + 11.days)
    create(:bookable_slot, guider: guider, start_at: holiday.start_at + 1.hour)
  end

  def when_they_download_utilisation_reports_for_a_date_range
    @page = Pages::NewUtilisationReport.new.tap(&:load)
    @page.date_range.set date_range
    @page.download.click
  end

  def then_they_get_utilisation_reports_in_that_range
    @page = Pages::ReportCsv.new
    expect_csv_content_disposition('utilisation-report-1479168000-1481587200.csv')
    expect(@page.csv).to eq(
      [
        [:date, :booked_appointments, :bookable_slots, :blocked_slots, :cancelled_appointments],
        ['2016-11-15', '0', '0', '0', '0'],
        ['2016-11-16', '1', '1', '0', '1'],
        ['2016-11-17', '1', '0', '0', '1'],
        ['2016-11-18', '0', '0', '0', '0'],
        ['2016-11-19', '0', '0', '0', '0'],
        ['2016-11-20', '0', '1', '0', '0'],
        ['2016-11-21', '0', '1', '0', '0'],
        ['2016-11-22', '0', '1', '0', '0'],
        ['2016-11-23', '0', '0', '1', '0'],
        ['2016-11-24', '0', '0', '0', '0'],
        ['2016-11-25', '0', '0', '1', '0'],
        ['2016-11-26', '0', '0', '0', '0'],
        ['2016-11-27', '0', '0', '0', '0'],
        ['2016-11-28', '0', '0', '0', '0'],
        ['2016-11-29', '0', '0', '0', '0'],
        ['2016-11-30', '0', '0', '0', '0'],
        ['2016-12-01', '0', '0', '0', '0'],
        ['2016-12-02', '0', '0', '0', '0'],
        ['2016-12-03', '0', '0', '0', '0'],
        ['2016-12-04', '0', '0', '0', '0'],
        ['2016-12-05', '0', '0', '0', '0'],
        ['2016-12-06', '0', '0', '0', '0'],
        ['2016-12-07', '0', '0', '0', '0'],
        ['2016-12-08', '0', '0', '0', '0'],
        ['2016-12-09', '0', '0', '0', '0'],
        ['2016-12-10', '0', '0', '0', '0'],
        ['2016-12-11', '0', '0', '0', '0'],
        ['2016-12-12', '0', '0', '0', '0'],
        ['2016-12-13', '0', '0', '0', '0']
      ]
    )
  end

  def expect_csv_content_disposition(file_name)
    expect(@page.content_disposition).to eq "attachment; filename=#{file_name}"
  end
end
