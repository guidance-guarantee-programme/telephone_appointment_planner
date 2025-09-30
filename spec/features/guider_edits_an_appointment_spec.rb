require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Guider edits an appointment' do
  scenario 'Guider views appointments and schedule banners' do
    given_the_user_is_a_guider do
      and_an_appointment_exists_for_today
      when_they_edit_the_appointment
      then_they_see_the_scheduled_today_banner
      when_they_edit_an_existing_appointment
      then_they_see_the_scheduled_later_banner
    end
  end

  scenario 'Guider attempts to reschedule a PSG appointment' do
    given_the_user_is_a_guider(organisation: :tpas) do
      and_an_existing_psg_appointment_exists
      when_they_view_the_appointments
      then_the_appointment_cannot_be_rescheduled
      when_they_edit_the_appointment_then_it_cannot_be_rescheduled
    end
  end

  scenario 'Guider attempts to reschedule a PSG appointment directly' do
    given_the_user_is_a_guider(organisation: :tpas) do
      and_an_existing_psg_appointment_exists
      when_the_guider_attempts_to_reschedule_an_appointment_directly
      then_they_are_redirected_to_the_search_page_with_a_warning
    end
  end

  scenario 'TPAS agent can resend an appointment confirmation email' do
    given_the_user_is_a_resource_manager(organisation: :tpas) do
      when_they_edit_an_existing_appointment
      then_they_can_resend_the_customer_email_confirmation
    end
  end

  scenario 'TP user resends an appointment confirmation email', js: true do
    given_the_user_is_an_agent(organisation: :tp) do
      when_they_edit_an_existing_appointment
      and_they_resend_the_customer_email_confirmation
      then_the_customer_email_confirmation_is_sent
      and_they_see_a_success_message
    end
  end

  scenario 'Successfully editing an appointment', js: true do
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

  def and_an_appointment_exists_for_today
    @appointment = create(:appointment, start_at: Time.current.middle_of_day)
  end

  def when_they_edit_the_appointment
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
    expect(@page).to be_displayed
  end

  def then_they_see_the_scheduled_today_banner
    expect(@page).to have_scheduled_today_banner
  end

  def then_they_see_the_scheduled_later_banner
    expect(@page).to have_scheduled_another_day_banner
  end

  def when_the_guider_attempts_to_reschedule_an_appointment_directly
    @page = Pages::RescheduleAppointment.new
    @page.load(id: @appointment_one.id)
  end

  def then_they_are_redirected_to_the_search_page_with_a_warning
    @page = Pages::Search.new
    expect(@page).to be_displayed
  end

  def and_an_existing_psg_appointment_exists
    # two appointments otherwise the search results redirect to the only one
    @appointment_one = create(:appointment, :due_diligence)
    @appointment_two = create(:appointment, :due_diligence)
  end

  def when_they_view_the_appointments
    @page = Pages::Search.new.tap(&:load)
  end

  def then_the_appointment_cannot_be_rescheduled
    @page.results.each { |result| expect(result).to have_no_reschedule }
  end

  def when_they_edit_the_appointment_then_it_cannot_be_rescheduled
    @page.results.first.edit.click

    @page = Pages::EditAppointment.new
    expect(@page).to be_displayed

    expect(@page).to have_no_reschedule
  end

  def when_they_edit_an_existing_appointment
    @appointment = create(:appointment)

    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)

    expect(@page).to be_displayed
  end

  def and_they_resend_the_customer_email_confirmation
    accept_confirm do
      @page.resend_email_confirmation.click
    end
  end

  def then_they_can_resend_the_customer_email_confirmation
    expect(@page).to have_resend_email_confirmation
  end

  def then_the_customer_email_confirmation_is_sent
    expect(@page).to have_flash_of_success

    expect(ActionMailer::Base.deliveries.first.subject).to eq('Pension Wise Appointment')
  end

  def and_they_have_a_third_party_booking
    @appointment = create(:appointment, :third_party_booking, :data_subject_consented)
  end

  def when_they_save_the_changes
    @page.submit.click
  end

  def and_they_have_an_appointment
    @appointment = create(:appointment, :third_party_booking, guider: current_user, dc_pot_confirmed: false)
  end

  def when_they_attempt_to_edit_the_appointment
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
  end

  def then_they_see_the_existing_details
    start_date = @appointment.start_at.to_date.to_formatted_s(:govuk_date_short)
    start_at_time = @appointment.start_at.to_formatted_s(:govuk_time)
    end_at_time = @appointment.end_at.to_formatted_s(:govuk_time)

    expect(@page.guider.text).to start_with(@appointment.guider.name)
    expect(@page.date_time.text).to eq("#{start_date}, #{start_at_time} - #{end_at_time}")
    expect(@page.created_date.text).to eq(@appointment.created_at.in_time_zone('London').to_fs(:govuk_date_short))
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
    @page.date_of_birth_day.set '2'
    @page.date_of_birth_month.set '2'
    @page.date_of_birth_year.set '1980'

    @page.wait_until_eligibility_reason_visible
    @page.eligibility_reason.select 'Ill health'

    @page.first_name.set 'Rick'
    @page.submit.click
  end

  def then_the_appointment_is_changed
    @page = Pages::EditAppointment.new
    expect(@page).to be_displayed
    expect(@page).to have_flash_of_success

    expect(@page.first_name.value).to eq('Rick')
    expect(@page).to have_text 'eligible as third party'
  end

  def and_the_customer_is_notified
    expect(ActionMailer::Base.deliveries).not_to be_empty
  end

  def and_they_see_a_success_message
    expect(@page).to have_flash_of_success
  end
end
# rubocop:enable Metrics/BlockLength
