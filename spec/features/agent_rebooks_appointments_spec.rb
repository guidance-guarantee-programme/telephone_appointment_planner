require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Agent rebooks appointments' do
  scenario 'CAS agent rebooks an appointment seeing only their availability', js: true do
    given_the_user_is_a_resource_manager(organisation: :cas) do
      travel_to '2022-06-20 09:00' do
        and_there_is_cross_organisational_availability
        and_an_existing_appointment_for_cas
        when_they_attempt_to_rebook_an_appointment
        they_default_to_cas_external_availability
        when_they_select_internal_availability
        then_they_see_only_their_availability
        when_they_switch_back_to_external_availability
        and_rebook_using_external_availability
        then_the_booking_is_placed_externally
      end
    end
  end

  scenario 'TPAS agent rebooks an appointment seeing external availability', js: true do
    given_the_user_is_a_resource_manager(organisation: :tpas) do
      travel_to '2022-06-20 09:00' do
        and_there_is_cross_organisational_availability
        and_an_existing_appointment_for_tpas
        when_they_attempt_to_rebook_an_appointment
        they_default_to_external_availability
        when_they_select_internal_availability
        then_they_see_internal_availability
      end
    end
  end

  scenario 'Agent rebooks an appointment' do
    given_the_user_is_an_agent do
      and_there_is_an_appointment
      and_they_rebook_an_appointment
      then_the_details_are_copied_over
      and_the_start_and_end_date_are_not_copied_over
      and_the_appointment_is_associated_with_the_original
    end
  end

  scenario 'Agent attempts to rebook a pending appointment' do
    given_the_user_is_an_agent do
      and_there_is_a_pending_appointment
      when_they_attempt_to_rebook_an_appointment
      then_they_are_told_to_change_the_original_appointment_status
    end
  end

  def and_an_existing_appointment_for_cas
    @appointment = create(:appointment, organisation: :cas, status: :cancelled_by_customer_sms)
  end

  def then_they_see_only_their_availability
    @page = Pages::NewAppointment.new
    expect(@page).to be_displayed

    @page.wait_until_slots_visible
    expect(@page).to have_slots(count: 1)
    expect(@page.slots.first).to have_text('11:00 1 guider')
  end

  def then_they_see_internal_availability
    @page.wait_until_slots_visible
    expect(@page).to have_slots(count: 1)
    expect(@page.slots.first).to have_text('9:00 1 guider')
  end

  def and_there_is_cross_organisational_availability
    create(:bookable_slot, start_at: Time.zone.parse('2022-06-24 09:00'))
    create(:bookable_slot, :cas, start_at: Time.zone.parse('2022-06-24 11:00'))
    create(:bookable_slot, :cas, start_at: Time.zone.parse('2022-06-20 11:00'))
  end

  def and_an_existing_appointment_for_tpas
    @appointment = create(:appointment, organisation: :tpas, status: :cancelled_by_customer_sms)
  end

  def then_they_see_external_availability
    @page = Pages::NewAppointment.new
    expect(@page).to be_displayed

    @page.wait_until_slots_visible
    expect(@page).to have_slots(count: 2)
  end

  def they_default_to_cas_external_availability
    @page = Pages::NewAppointment.new
    expect(@page).to be_displayed

    expect(@page).to have_no_slots

    @page.next_period.click
    @page.wait_until_slots_visible
    expect(@page).to have_slots(count: 1)
    expect(@page.slots.first).to have_text('09:00 1 guider')
  end

  def when_they_switch_back_to_external_availability
    @page.internal_availability.uncheck
    @page.wait_until_slots_visible
  end

  def and_rebook_using_external_availability
    @page.choose_slot('09:00')
    @page.preview_appointment.click

    @page = Pages::PreviewAppointment.new
    expect(@page).to be_displayed
    @page.confirm_appointment.click
  end

  def then_the_booking_is_placed_externally
    @rebooked = Appointment.last

    expect(@rebooked.guider.organisation).to eq('TPAS')
    expect(@rebooked.rebooked_from_id).to eq(@appointment.id)

    expect(@page).to have_text(/The appointment \#\d+ has been booked for/)
  end

  def they_default_to_external_availability
    @page = Pages::NewAppointment.new
    expect(@page).to be_displayed

    @page.next_period.click
    @page.wait_until_slots_visible
    expect(@page).to have_slots(count: 1)
    expect(@page.slots.first).to have_text('11:00 1 guider')
  end

  def when_they_select_internal_availability
    @page.internal_availability.check
  end

  def and_they_do_not_see_the_internal_availability_toggle
    expect(@page).to have_no_internal_availability
  end

  def and_there_is_a_pending_appointment
    @appointment = create(:appointment)
  end

  def when_they_attempt_to_rebook_an_appointment
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
    @page.rebook.click
  end

  def then_they_are_told_to_change_the_original_appointment_status
    # redirected back
    expect(@page).to be_displayed

    expect(@page).to have_content(I18n.t('appointments.rebooking'))
  end

  def and_there_is_an_appointment
    @appointment = create(
      :appointment,
      :third_party_booking,
      :with_data_subject_consent_evidence,
      status: :cancelled_by_customer_sms
    )
  end

  def and_they_rebook_an_appointment
    @page = Pages::Search.new.tap(&:load)
    @page.rebook.click

    @page = Pages::NewAppointment.new
    expect(@page).to be_displayed
  end

  def then_the_details_are_copied_over
    expect(@page.first_name.value).to eq @appointment.first_name
    expect(@page.last_name.value).to eq @appointment.last_name
    expect(@page.email.value).to eq @appointment.email
    expect(@page.phone.value).to eq @appointment.phone
    expect(@page.mobile.value).to eq @appointment.mobile
    expect(@page.date_of_birth_day.value).to eq @appointment.date_of_birth.day.to_s
    expect(@page.date_of_birth_month.value).to eq @appointment.date_of_birth.month.to_s
    expect(@page.date_of_birth_year.value).to eq @appointment.date_of_birth.year.to_s
    expect(@page.memorable_word.value).to eq @appointment.memorable_word
    expect(@page.notes.value).to eq @appointment.notes
    expect(@page.gdpr_consent_yes).to be_checked
  end

  def and_the_start_and_end_date_are_not_copied_over
    expect(@page.start_at.value).to be_blank
    expect(@page.end_at.value).to be_blank
  end

  def and_the_appointment_is_associated_with_the_original
    expect(@page.original_appointment.text).to eq("Rebooked from ##{@appointment.id}")
  end
end
# rubocop:enable Metrics/BlockLength
