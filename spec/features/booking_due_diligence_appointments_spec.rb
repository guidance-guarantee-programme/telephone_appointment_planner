require 'rails_helper'

RSpec.feature 'Booking due diligence appointments', js: true, driver: :poltergeist do
  let(:day) { BusinessDays.from_now(3) }

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

  def and_the_appointment_can_be_rebooked
    @appointment.cancelled_by_pension_wise!
  end

  def when_they_attempt_to_rebook
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)

    @page.rebook.click

    @page = Pages::NewAppointment.new
    expect(@page).to be_displayed
  end

  def when_they_rebook_the_appointment
    @page.start_at.set day.change(hour: 14, min: 30).to_s
    @page.end_at.set   day.change(hour: 15, min: 40).to_s
    @page.preview_appointment.click

    @page = Pages::PreviewAppointment.new
    @page.confirm_appointment.click
  end

  def then_the_new_appointment_is_created
    @rebooked_appointment = Appointment.last

    expect(@rebooked_appointment.rebooked_from).to eq(@appointment)
  end

  def and_an_due_diligence_appointment_exists
    @appointment = create(:appointment, :due_diligence, start_at: Time.zone.parse('2021-04-08 10:30'))
  end

  def when_they_attempt_to_reschedule_the_appointment
    @page = Pages::RescheduleAppointment.new
    @page.load(id: @appointment.id)
  end

  def when_they_reschedule_the_appointment
    @page.start_at.set day.change(hour: 14, min: 30).to_s
    @page.end_at.set   day.change(hour: 15, min: 40).to_s

    @page.reschedule.click
  end

  def then_the_original_appointment_is_rescheduled
    expect(@appointment.reload.start_at).to eq(Time.zone.parse('2021-04-08 14:30'))
  end

  def then_the_due_diligence_appointment_is_booked
    @appointment = Appointment.last
    expect(@appointment).to be_due_diligence
  end

  def and_they_accept_the_appointment_preview
    @page = Pages::PreviewAppointment.new
    expect(@page).to be_displayed
    expect(@page).to have_content('PSG appointment')

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

    expect(@page.hidden_where_you_heard.value).to eq('2') # A Pension Provider
  end

  def when_they_fill_in_the_appointment_details
    @page.start_at.set day.change(hour: 14, min: 30).to_s
    @page.end_at.set   day.change(hour: 15, min: 40).to_s

    @page.date_of_birth_day.set '23'
    @page.date_of_birth_month.set '10'
    @page.date_of_birth_year.set '1950'
    @page.first_name.set 'Some'
    @page.last_name.set 'Person'
    @page.email.set 'email@example.org'
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
  end

  def and_they_are_told_they_are_booking_due_diligence
    expect(@page).to have_due_diligence_banner
  end
end
