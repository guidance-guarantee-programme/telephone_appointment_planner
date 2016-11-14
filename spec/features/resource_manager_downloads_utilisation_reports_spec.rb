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

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def and_there_are_data
    guider = create(:guider)

    # booked appointments
    appointments = [
      create(:appointment, guider: guider, start_at: start_at + 1.day),
      create(:appointment, guider: guider, start_at: start_at + 2.days)
    ]

    # ignored appointment
    create(:appointment, start_at: now + 2.days)

    # bookable slots
    create(:bookable_slot, start_at: start_at + 5.days)
    create(:bookable_slot, start_at: start_at + 6.days)
    create(:bookable_slot, start_at: start_at + 7.days)

    # ignored slot (out of date range)
    create(:bookable_slot, start_at: start_at - 5.days)

    # blocked slot (obsured by appointment)
    create(:bookable_slot, guider: guider, start_at: appointments.first.start_at, end_at: appointments.first.end_at)
    # blocked slot (obsured by global holiday)
    holiday = create(:bank_holiday, start_at: start_at + 8.days, end_at: start_at + 9.days)
    create(:bookable_slot, start_at: holiday.start_at + 1.hour)
    # blocked slot (obscured by user holiday)
    guider = create(:guider)
    holiday = create(:holiday, user: guider, start_at: start_at + 10.days, end_at: start_at + 11.days)
    create(:bookable_slot, guider: guider, start_at: holiday.start_at + 1.hour)
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def when_they_download_utilisation_reports_for_a_date_range
    @page = Pages::NewUtilisationReport.new.tap(&:load)
    @page.date_range.set date_range
    @page.download.click
  end

  def then_they_get_utilisation_reports_in_that_range
    @page = Pages::ReportCsv.new
    expect_csv_content_disposition('utilisation-report-1479168000-1481587200.csv')
    expect_utilisation_csv([2, 3, 3])
  end

  def expect_csv_content_disposition(file_name)
    expect(@page.content_disposition).to eq "attachment; filename=#{file_name}"
  end

  # rubocop:disable Metrics/AbcSize
  def expect_utilisation_csv(utilisation)
    expect(@page.csv.count).to eq 2
    expect(@page.csv.first).to eq [:booked_appointments, :bookable_slots, :blocked_slots]
    expect(@page.csv.second.map(&:to_i)).to eq utilisation
  end
  # rubocop:enable Metrics/AbcSize
end
