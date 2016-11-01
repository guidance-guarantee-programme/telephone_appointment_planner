require 'rails_helper'

RSpec.feature 'Resource manager views reports' do
  scenario 'by appointment creation date' do
    given_the_user_is_a_resource_manager do
      and_there_are_data
      when_they_download_reports_by_appointment_created_at
      then_they_get_reports_by_appointment_created_at
    end
  end

  scenario 'by appointment start' do
    given_the_user_is_a_resource_manager do
      and_there_are_data
      when_they_download_reports_by_appointment_start_at
      then_they_get_reports_by_appointment_start_at
    end
  end

  let(:start_at) do
    BusinessDays.from_now(10)
  end

  let(:created_at) do
    BusinessDays.from_now(20)
  end

  def and_there_are_data
    @appointment_with_created_at = create(:appointment, created_at: created_at)
    @appointment_with_start_at = create(:appointment, start_at: start_at)
  end

  def date_range_enclosing(date)
    [
      (date - 1.day).strftime(Report::DATE_RANGE_PICKER_FORMAT),
      (date + 1.day).strftime(Report::DATE_RANGE_PICKER_FORMAT)
    ].join(' - ')
  end

  def when_they_download_reports_by_appointment_created_at
    @page = Pages::NewReport.new.tap(&:load)
    @page.where.select 'Appointment creation date'
    @page.is_within.set date_range_enclosing(created_at)
    @page.download.click
  end

  def then_they_get_reports_by_appointment_created_at
    @page = Pages::ReportCsv.new
    expect_appointment_csv(@appointment_with_created_at)
  end

  def when_they_download_reports_by_appointment_start_at
    @page = Pages::NewReport.new.tap(&:load)
    @page.where.select 'Appointment start'
    @page.is_within.set date_range_enclosing(start_at)
    @page.download.click
  end

  def then_they_get_reports_by_appointment_start_at
    @page = Pages::ReportCsv.new
    expect_appointment_csv(@appointment_with_start_at)
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def expect_appointment_csv(appointment)
    expect(@page.content_disposition).to eq 'attachment; filename=report.csv'
    expect(@page.csv.count).to eq 2
    expect(@page.csv.first).to eq Report::EXPORTABLE_ATTRIBUTES
    expect(@page.csv.second).to match_array [
      appointment.created_at.to_s,
      appointment.agent.name,
      appointment.guider.name,
      appointment.start_at.to_s,
      '60 minutes',
      appointment.status,
      appointment.first_name,
      appointment.last_name,
      appointment.date_of_birth.to_s,
      appointment.id.to_s,
      appointment.memorable_word,
      appointment.phone,
      appointment.mobile,
      appointment.email
    ]
  end
end
