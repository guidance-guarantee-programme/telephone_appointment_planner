require 'rails_helper'

RSpec.feature 'Resource manager downloads appointment reports' do
  scenario 'Non TPAS user' do
    given_the_user_is_a_resource_manager(organisation: :tp) do
      when_they_visit_the_appointment_report
      then_they_do_not_see_the_type_field
    end
  end

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

  scenario 'appointment with date at end of range is included' do
    given_the_user_is_a_resource_manager do
      travel_to now do
        and_there_is_an_appointment_at_the_end_of_the_date_range
        when_they_download_reports_by_appointment_start_at
        then_they_get_reports_by_appointment_start_at
        and_the_appointment_is_included_in_the_result
      end
    end
  end

  scenario 'The user is a contact centre team leader' do
    given_the_user_is_a_contact_centre_team_leader do
      travel_to now do
        and_there_are_data
        when_they_download_reports_by_appointment_start_at
        then_they_get_reports_across_all_providers
      end
    end
  end

  scenario 'date ranges must be provided' do
    given_the_user_is_a_resource_manager do
      when_they_attempt_to_download_reports_without_a_date_range
      then_they_see_a_validation_message
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

  def when_they_visit_the_appointment_report
    @page = Pages::NewAppointmentReport.new.tap(&:load)
  end

  def then_they_do_not_see_the_type_field
    expect(@page).to have_no_pension_wise
    expect(@page).to have_no_due_diligence
  end

  def when_they_attempt_to_download_reports_without_a_date_range
    @page = Pages::NewAppointmentReport.new.tap(&:load)
    @page.where.select 'Appointment creation date'
    @page.download.click
  end

  def then_they_see_a_validation_message
    expect(@page).to have_errors
  end

  def and_there_are_data
    @appointment_with_created_at  = create(:appointment, created_at: created_at)
    @appointment_with_start_at    = create(:appointment, start_at: start_at)
    @tp_appointment_with_start_at = create(:appointment, start_at: start_at, guider: create(:guider, :tp))
    @due_diligence_appointment    = create(:appointment, :due_diligence, start_at: start_at)
  end

  def and_there_is_an_appointment_at_the_end_of_the_date_range
    @appointment_with_start_at = create(:appointment, start_at: start_at.end_of_day)
  end

  def when_they_download_reports_by_appointment_created_at
    @page = Pages::NewAppointmentReport.new.tap(&:load)
    @page.where.select 'Appointment creation date'
    @page.date_range.set date_range_enclosing(created_at)
    @page.pension_wise.set true
    @page.download.click
  end

  def then_they_get_reports_by_appointment_created_at
    @page = Pages::ReportCsv.new
    expect_csv_content_disposition('report-1479427200-1479427200created_at.csv')
    expect_appointment_csv(@appointment_with_created_at)
  end

  def when_they_download_reports_by_appointment_start_at
    @page = Pages::NewAppointmentReport.new.tap(&:load)
    @page.where.select 'Appointment start'
    @page.date_range.set date_range_enclosing(start_at)
    @page.pension_wise.set true
    @page.download.click
  end

  def then_they_get_reports_by_appointment_start_at
    @page = Pages::ReportCsv.new
    expect_csv_content_disposition('report-1478217600-1478217600start_at.csv')
    expect_appointment_csv(@appointment_with_start_at)
  end

  def then_they_get_reports_across_all_providers
    @page = Pages::ReportCsv.new
    expect_csv_content_disposition('report-1478217600-1478217600start_at.csv')
    expect(@page.csv.count).to eq(3)
  end

  def and_the_appointment_is_included_in_the_result
    @page = Pages::ReportCsv.new
    expect_csv_content_disposition('report-1478217600-1478217600start_at.csv')
    expect_appointment_csv(@appointment_with_start_at)
  end

  def date_range_enclosing(date)
    [
      I18n.l(date, format: :date_range_picker),
      I18n.l(date, format: :date_range_picker)
    ].join(' - ')
  end

  def expect_csv_content_disposition(file_name)
    expect(@page.content_disposition).to eq "attachment; filename=\"#{file_name}\""
  end

  def expect_appointment_csv(appointment)
    expect(@page.csv.count).to eq 2
    expect(@page.csv.first).to eq [
      :created_at,
      :booked_by,
      :guider,
      :date,
      :duration,
      :status,
      :status_changed,
      :summary_document_created,
      :first_name,
      :last_name,
      :notes,
      :gdpr_consent,
      :date_of_birth,
      :booking_reference,
      :memorable_word,
      :phone,
      :mobile,
      :email,
      :third_party_booking,
      :data_subject_consent_obtained,
      :data_subject_consent_attached,
      :power_of_attorney,
      :power_of_attorney_attached,
      :printed_consent_form_required,
      :email_consent_form_required
    ]

    expect(@page.csv.second).to match_array [
      appointment.created_at.to_s,
      appointment.agent.name,
      appointment.guider.name,
      appointment.start_at.to_s,
      '60 minutes',
      appointment.status,
      appointment.status_transitions.last.created_at,
      'No', # summary document created
      appointment.first_name,
      appointment.last_name,
      appointment.notes,
      appointment.gdpr_consent,
      appointment.date_of_birth.to_s,
      appointment.id.to_s,
      appointment.memorable_word,
      appointment.phone,
      appointment.mobile,
      appointment.email,
      'No', 'No', 'No', 'No', 'No', 'No', 'No' # third party booking flags
    ]
  end
end
