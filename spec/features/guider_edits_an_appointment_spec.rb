require 'rails_helper'

RSpec.feature 'Guider edits an appointment' do
  scenario 'Successfully editing an appointment' do
    given_the_user_is_a_guider(organisation: :cas) do
      and_they_have_an_appointment
      when_they_attempt_to_edit_the_appointment
      then_they_see_the_existing_details
      when_they_modify_the_appointment
      then_the_appointment_is_changed
      and_the_customer_is_notified
      and_they_see_a_success_message
    end
  end

  scenario 'Attaching consent evidence to an existing appointment', js: true do
    given_the_user_is_a_guider do
      and_they_have_a_third_party_booking
      when_they_attempt_to_edit_the_appointment
      and_they_attach_the_consent_evidence
      when_they_save_the_changes
      then_the_appointment_has_attached_evidence
      when_they_attach_power_of_attorney_evidence
      when_they_save_the_changes
      then_the_power_of_attorney_evidence_is_attached
    end
  end

  def and_they_have_a_third_party_booking
    @appointment = create(:appointment, :third_party_booking, :data_subject_consented)
  end

  def and_they_attach_the_consent_evidence
    expect(@page).to have_data_subject_consent_evidence

    @page.attach_file('Data subject consent evidence', Rails.root.join('spec', 'fixtures', 'evidence.pdf'))
  end

  def when_they_save_the_changes
    @page.submit.click
  end

  def then_the_appointment_has_attached_evidence
    expect(@page).to have_consent_download
  end

  def when_they_attach_power_of_attorney_evidence
    @page.data_subject_consent_obtained.set(false)
    @page.power_of_attorney.set(true)

    @page.attach_file('Power of attorney evidence', Rails.root.join('spec', 'fixtures', 'evidence.pdf'))
  end

  def then_the_power_of_attorney_evidence_is_attached
    expect(@page).to have_power_of_attorney_download
  end

  def and_they_have_an_appointment
    @appointment = create(:appointment, :third_party_booking, guider: current_user, dc_pot_confirmed: false)
  end

  def when_they_attempt_to_edit_the_appointment
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
  end

  def then_they_see_the_existing_details
    start_date = @appointment.start_at.to_date.to_s(:govuk_date_short)
    start_at_time = @appointment.start_at.to_s(:govuk_time)
    end_at_time = @appointment.end_at.to_s(:govuk_time)

    expect(@page.guider.text).to eq(@appointment.guider.name)
    expect(@page.date_time.text).to eq("#{start_date}, #{start_at_time} - #{end_at_time}")
    expect(@page.created_date.text).to eq(@appointment.created_at.in_time_zone('London').to_s(:govuk_date_short))
    expect(@page.first_name.value).to eq(@appointment.first_name)
    expect(@page.last_name.value).to eq(@appointment.last_name)
    expect(@page.email.value).to eq(@appointment.email)
    expect(@page.phone.value).to eq(@appointment.phone)
    expect(@page.mobile.value).to eq(@appointment.mobile)
    expect(@page.memorable_word.value).to eq(@appointment.memorable_word)
    expect(@page.notes.value).to eq(@appointment.notes)
    expect(@page.gdpr_consent_yes).to be_checked
    expect(@page.status.value).to eq(@appointment.status)

    expect(@page).to have_dc_pot_unsure_banner
    expect(@page).to have_third_party_booked_banner
  end

  def when_they_modify_the_appointment
    @page.first_name.set 'Rick'
    @page.submit.click
  end

  def then_the_appointment_is_changed
    expect(@appointment.reload.first_name).to eq('Rick')
  end

  def and_the_customer_is_notified
    expect(ActionMailer::Base.deliveries).not_to be_empty
  end

  def and_they_see_a_success_message
    expect(@page).to have_flash_of_success
  end
end
