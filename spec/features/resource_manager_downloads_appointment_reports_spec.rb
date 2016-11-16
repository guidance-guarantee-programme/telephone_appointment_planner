require 'rails_helper'

RSpec.feature 'Resource manager downloads appointment reports' do
  scenario 'by appointment creation date' do
    given_the_user_is_a_resource_manager do
      travel_to now do
        and_there_are_data
        when_they_download_reports_by_appointment_created_at
        then_they_get_reports_by_appointment_created_at
      end
    end
  end

  scenario 'by appointment start' do
    given_the_user_is_a_resource_manager do
      travel_to now do
        and_there_are_data
        when_they_download_reports_by_appointment_start_at
        then_they_get_reports_by_appointment_start_at
      end
    end
  end

  let(:now) do
    Date.new(2016, 10, 23)
  end

  let(:start_at) do
    BusinessDays.from_now(10).to_date
  end

  let(:created_at) do
    BusinessDays.from_now(20).to_date
  end

  def and_there_are_data
    @appointment_with_created_at = create(:appointment, created_at: created_at)
    @appointment_with_start_at = create(:appointment, start_at: start_at)
  end

  def date_range_enclosing(date)
    [
      I18n.l(date - 1.day, format: :date_range_picker),
      I18n.l(date + 1.day, format: :date_range_picker)
    ].join(' - ')
  end

  def when_they_download_reports_by_appointment_created_at
    @page = Pages::NewAppointmentReport.new.tap(&:load)
    @page.where.select 'Appointment creation date'
    @page.date_range.set date_range_enclosing(created_at)
    @page.download.click
  end

  def then_they_get_reports_by_appointment_created_at
    @page = Pages::ReportCsv.new
    expect_csv_content_disposition('report-1479340800-1479513600created_at.csv')
    expect_appointment_csv(@appointment_with_created_at)
  end

  def when_they_download_reports_by_appointment_start_at
    @page = Pages::NewAppointmentReport.new.tap(&:load)
    @page.where.select 'Appointment start'
    @page.date_range.set date_range_enclosing(start_at)
    @page.download.click
  end

  def then_they_get_reports_by_appointment_start_at
    @page = Pages::ReportCsv.new
    expect_csv_content_disposition('report-1478131200-1478304000start_at.csv')
    expect_appointment_csv(@appointment_with_start_at)
  end

  def expect_csv_content_disposition(file_name)
    expect(@page.content_disposition).to eq "attachment; filename=#{file_name}"
  end

  def expect_appointment_csv(appointment)
    expect(@page.csv.count).to eq 2
    expect(@page.csv.first).to eq AppointmentReport::EXPORTABLE_ATTRIBUTES
    expect(@page.csv.second).to match_array [
      appointment.created_at.to_s,
      appointment.agent.name,
      appointment.guider.name,
      appointment.start_at.to_s,
      '60 minutes',
      appointment.status,
      appointment.first_name,
      appointment.last_name,
      appointment.notes,
      appointment.opt_out_of_market_research.to_s,
      appointment.date_of_birth.to_s,
      appointment.id.to_s,
      appointment.memorable_word,
      appointment.phone,
      appointment.mobile,
      appointment.email
    ]
  end
end
