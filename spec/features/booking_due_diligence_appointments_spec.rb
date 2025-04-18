require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Booking due diligence appointments', js: true do
  let(:day) { BusinessDays.from_now(3) }

  scenario 'Failing validation during an initial booking creation' do
    travel_to '2021-04-05 10:00' do
      given_the_user_is_a_resource_manager(organisation: :tpas) do
        and_slots_exist_for_due_diligence_availability
        when_they_attempt_to_book_an_due_diligence_appointment
        then_they_see_only_due_diligence_availability
        when_they_attempt_to_book_with_invalid_fields
        then_they_see_validation_messages
        then_they_see_only_due_diligence_availability
      end
    end
  end

  scenario 'TPAS resource manager attempts to book an DD appointment' do
    travel_to '2021-04-05 10:00' do
      given_the_user_is_a_resource_manager(organisation: :tpas) do
        and_slots_exist_for_general_availability
        and_slots_exist_for_due_diligence_availability
        when_they_attempt_to_book_an_due_diligence_appointment
        then_they_see_only_due_diligence_availability
        and_they_are_told_they_are_booking_due_diligence
        and_they_are_presented_with_the_correct_fields
        when_they_fill_in_the_appointment_details
        and_they_accept_the_appointment_preview
        then_the_due_diligence_appointment_is_booked
      end
    end
  end

  scenario 'TPAS resource manager attempts to reschedule an DD appointment' do
    travel_to '2021-04-05 10:00' do
      given_the_user_is_a_resource_manager(organisation: :tpas) do
        and_slots_exist_for_general_availability
        and_slots_exist_for_due_diligence_availability
        and_an_due_diligence_appointment_exists
        when_they_attempt_to_reschedule_the_appointment
        then_they_see_only_due_diligence_availability
        when_they_reschedule_the_appointment
        then_the_original_appointment_is_rescheduled
      end
    end
  end

  scenario 'TPAS resource manager attempts to rebook an DD appointment' do
    travel_to '2021-04-05 10:00' do
      given_the_user_is_a_resource_manager(organisation: :tpas) do
        and_slots_exist_for_general_availability
        and_slots_exist_for_due_diligence_availability
        and_an_due_diligence_appointment_exists
        and_the_appointment_can_be_rebooked
        when_they_attempt_to_rebook
        then_they_see_only_due_diligence_availability
        and_they_are_presented_with_the_correct_fields
        when_they_rebook_the_appointment
        then_the_new_appointment_is_created
      end
    end
  end

  def when_they_attempt_to_book_with_invalid_fields
    @page.choose_slot('14:30')

    @page.date_of_birth_day.set '23'
    @page.date_of_birth_month.set '10'
    @page.date_of_birth_year.set '1950'

    @page.preview_appointment.click
  end

  def then_they_see_validation_messages
    expect(@page).to have_fields_with_errors
  end

  def and_the_appointment_can_be_rebooked
    @appointment.update!(status: :cancelled_by_pension_wise, secondary_status: '31')
  end

  def when_they_attempt_to_rebook
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)

    @page.rebook.click

    @page = Pages::NewAppointment.new
    expect(@page).to be_displayed
    expect(@page).to have_no_internal_availability
  end

  def when_they_rebook_the_appointment
    @page.choose_slot('14:30')
    @page.preview_appointment.click

    @page = Pages::PreviewAppointment.new
    @page.confirm_appointment.click
  end

  def then_the_new_appointment_is_created
    @page = Pages::Search.new
    expect(@page).to be_displayed
    expect(@page).to have_flash_of_success
  end

  def and_an_due_diligence_appointment_exists
    @appointment = create(:appointment, :due_diligence, start_at: Time.zone.parse('2021-04-08 10:30'))
  end

  def when_they_attempt_to_reschedule_the_appointment
    @page = Pages::RescheduleAppointment.new
    @page.load(id: @appointment.id)
  end

  def when_they_reschedule_the_appointment
    @page.client_rescheduled.set(true)
    @page.wait_until_via_phone_visible
    @page.via_phone.set(true)
    @page.choose_slot('14:30')
    @page.reschedule.click
  end

  def then_the_original_appointment_is_rescheduled
    @page = Pages::EditAppointment.new
    expect(@page).to be_displayed
    expect(@page).to have_flash_of_success
    expect(@page.date_time).to have_text('8 Apr 2021, 2:30pm - 3:30pm')
  end

  def then_the_due_diligence_appointment_is_booked
    @page = Pages::EditAppointment.new
    expect(@page).to be_displayed
    expect(@page).to have_flash_of_success

    expect(@page).to have_due_diligence_banner
    expect(@page.country_code.value).to have_text('FR')
  end

  def and_they_accept_the_appointment_preview
    @page = Pages::PreviewAppointment.new
    expect(@page).to be_displayed
    expect(@page).to have_content('PSG appointment')
    expect(@page).to have_content('France')

    @page.confirm_appointment.click
  end

  def and_they_are_presented_with_the_correct_fields
    expect(@page).to have_no_third_party_booked
    expect(@page).to have_no_smarter_signposted
    expect(@page).to have_no_type_of_appointment_standard
    expect(@page).to have_no_type_of_appointment_50_54
    expect(@page).to have_no_gdpr_consent_yes
    expect(@page).to have_no_gdpr_consent_no
    expect(@page).to have_no_gdpr_consent_no_response
    expect(@page).to have_no_small_pots
    expect(@page).to have_no_attended_digital_yes
    expect(@page).to have_no_attended_digital_no
    expect(@page).to have_no_attended_digital_not_sure
    expect(@page).to have_text('Postal address')
    expect(@page).to_not have_text('Confirmation address')

    expect(@page.hidden_where_you_heard.value).to eq('2') # A Pension Provider
  end

  def when_they_fill_in_the_appointment_details
    @page.choose_slot('14:30')

    @page.date_of_birth_day.set '23'
    @page.date_of_birth_month.set '10'
    @page.date_of_birth_year.set '1950'
    @page.first_name.set 'Some'
    @page.last_name.set 'Person'
    @page.email.set 'email@example.org'
    @page.country_of_residence.select('France')
    @page.phone.set '0208 252 4729'
    @page.mobile.set '07715 930 459'
    @page.memorable_word.set 'lozenge'
    @page.accessibility_requirements.set false
    @page.referrer.set 'Big Pensions PLC'

    @page.preview_appointment.click
  end

  def and_slots_exist_for_due_diligence_availability
    create(:bookable_slot, :due_diligence, start_at: Time.zone.parse('2021-04-08 14:30'))
  end

  def then_they_see_only_due_diligence_availability
    @page.wait_until_calendar_events_visible

    # they're deduplicated properly given one is PW and one is DD
    expect(@page).to have_calendar_events(count: 1)
    expect(@page.calendar_events.first).to have_text('April 8th 2021 14:30 1 guider available')
  end

  def and_slots_exist_for_general_availability
    create(:bookable_slot, start_at: Time.zone.parse('2021-04-08 14:30'))
  end

  def when_they_attempt_to_book_an_due_diligence_appointment
    @page = Pages::NewAppointment.new
    @page.load(query: { schedule_type: User::DUE_DILIGENCE_SCHEDULE_TYPE })

    expect(@page).to be_displayed
    expect(@page).to have_no_internal_availability
  end

  def and_they_are_told_they_are_booking_due_diligence
    expect(@page).to have_due_diligence_banner
  end
end
# rubocop:enable Metrics/BlockLength
