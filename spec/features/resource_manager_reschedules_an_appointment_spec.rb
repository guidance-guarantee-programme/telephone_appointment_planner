require 'rails_helper'

RSpec.feature 'Resource manager reschedules an appointment', js: true do
  scenario 'TPAS resource manager reschedules another organisation’s appointment' do
    given_the_user_is_a_resource_manager(organisation: :tpas) do
      travel_to '2022-06-20 13:00' do
        and_there_is_a_tpas_guider_slot
        and_there_is_a_cas_guider_slot
        and_there_is_a_cas_appointment
        when_they_attempt_to_reschedule_the_appointment
        then_they_see_only_cas_slots
        and_they_do_not_see_the_internal_availability_toggle
      end
    end
  end

  scenario 'TPAS resource manager reschedules their own organisation’s appointment' do
    given_the_user_is_a_resource_manager(organisation: :tpas) do
      travel_to '2022-06-20 13:00' do
        and_there_are_matching_available_slots_across_multiple_organisations
        and_there_is_a_tpas_appointment
        when_they_attempt_to_reschedule_the_appointment
        and_they_choose_the_one_available_slot
        then_the_appointment_is_rescheduled_still_belonging_to_tpas
      end
    end
  end

  scenario 'TPAS resource manager creates an appointment from internal availability' do
    given_the_user_is_a_resource_manager(organisation: :tpas) do
      travel_to '2022-06-20 13:00' do
        and_there_are_matching_available_slots_across_multiple_organisations
        when_they_choose_an_internal_slot
        and_they_place_a_booking
        then_the_resulting_appointment_is_correctly_allocated
      end
    end
  end

  scenario 'TPAS resource manager creates an appointment from external availability' do
    given_the_user_is_a_resource_manager(organisation: :tpas) do
      travel_to '2022-06-20 13:00' do
        and_there_are_many_tpas_slots_and_one_external_slot
        when_they_choose_the_external_slot
        and_they_place_a_booking
        then_the_resulting_appointment_is_correctly_allocated_to_cas
      end
    end
  end

  scenario 'CAS resource manager creates an appointment' do
    given_the_user_is_a_resource_manager(organisation: :cas) do
      travel_to '2022-06-20 13:00' do
        and_there_are_matching_available_slots_across_multiple_organisations
        when_they_choose_their_slot
        and_they_place_a_booking
        then_the_resulting_appointment_is_correctly_allocated_to_cas
      end
    end
  end

  def and_there_are_many_tpas_slots_and_one_external_slot
    start_at = Time.zone.parse('2022-06-24 09:00')

    create(:bookable_slot, :cas, start_at: start_at)
    # create many TPAS slots to increase the chance of random selection
    create_list(:bookable_slot, 10, start_at: start_at)
  end

  def when_they_choose_the_external_slot
    @page = Pages::NewAppointment.new.tap(&:load)
    @page.next_period.click

    @page.wait_until_slots_visible
    @page.choose_slot('09:00')
  end

  def when_they_choose_their_slot
    @page = Pages::NewAppointment.new.tap(&:load)
    expect(@page).to have_no_internal_availability

    @page.next_period.click
    @page.wait_until_slots_visible
    @page.choose_slot('09:00')
  end

  def then_the_resulting_appointment_is_correctly_allocated_to_cas
    @page.confirm_appointment.click

    @page = Pages::EditAppointment.new
    expect(@page).to be_displayed

    expect(@page.guider).to have_text('CAS')
  end

  def when_they_choose_an_internal_slot
    @page = Pages::NewAppointment.new.tap(&:load)
    @page.internal_availability.set true
    @page.next_period.click
    @page.wait_until_slots_visible
    @page.choose_slot('09:00')
  end

  def and_they_place_a_booking
    @page.date_of_birth_day.set '23'
    @page.date_of_birth_month.set '10'
    @page.date_of_birth_year.set '1950'
    @page.first_name.set 'Some'
    @page.last_name.set 'Person'
    @page.email.set 'email@example.org'
    @page.phone.set '0208 252 4729'
    @page.mobile.set '07715 930 459'
    @page.memorable_word.set 'lozenge'
    @page.gdpr_consent_yes.set true
    @page.type_of_appointment_standard.set true
    @page.where_you_heard.select 'Other'
    @page.preview_appointment.click

    @page = Pages::PreviewAppointment.new
    expect(@page).to be_displayed
  end

  def then_the_resulting_appointment_is_correctly_allocated
    @page.confirm_appointment.click

    @page = Pages::EditAppointment.new
    expect(@page).to be_displayed

    expect(@page.guider).to have_text('TPAS')
  end

  def and_there_are_matching_available_slots_across_multiple_organisations
    start_at = Time.zone.parse('2022-06-24 09:00')

    create(:bookable_slot, start_at: start_at)
    create(:bookable_slot, :cas, start_at: start_at)
    create(:bookable_slot, :ni, start_at: start_at)
    create(:bookable_slot, :lancs_west, start_at: start_at)
    create(:bookable_slot, :derbyshire_districts, start_at: start_at)
    create(:bookable_slot, :wallsend, start_at: start_at)
  end

  def and_there_is_a_tpas_appointment
    @appointment = create(:appointment, organisation: :tpas)
  end

  def and_they_choose_the_one_available_slot
    @page.next_period.click
    @page.wait_until_slots_visible

    expect(@page).to have_slots(count: 1)
    expect(@page.slots.first).to have_text('09:00 1 guider available')

    @page.slots.first.click
    @page.reschedule.click
  end

  def then_the_appointment_is_rescheduled_still_belonging_to_tpas
    @page = Pages::EditAppointment.new
    expect(@page).to be_displayed(id: @appointment.id)
    expect(@page).to have_flash_of_success
  end

  def and_there_is_a_tpas_guider_slot
    create(:bookable_slot, start_at: Time.zone.parse('2022-06-24 09:00'))
  end

  def and_there_is_a_cas_guider_slot
    create(:bookable_slot, :cas, start_at: Time.zone.parse('2022-06-24 11:00'))
  end

  def and_there_is_a_cas_appointment
    @appointment = create(:appointment, organisation: :cas)
  end

  def then_they_see_only_cas_slots
    @page.next_period.click
    @page.wait_until_slots_visible

    expect(@page).to have_slots(count: 1)
    expect(@page.slots.first).to have_text('11:00')
  end

  def and_they_do_not_see_the_internal_availability_toggle
    expect(@page).to have_no_internal_availability
  end

  scenario 'Rebooking with ad-hoc allocation' do
    given_the_user_is_a_resource_manager do
      travel_to '2017-12-27 13:00 utc' do
        and_there_is_a_cancelled_appointment
        and_there_are_several_guiders
        when_they_attempt_to_rebook_the_appointment
        and_select_ad_hoc_allocation
        and_rebook_the_appointment
        then_the_appointment_is_rebooked
      end
    end
  end

  scenario 'Rescheduling with ad-hoc allocation' do
    given_the_user_is_a_resource_manager do
      travel_to '2017-12-27 13:00 utc' do
        and_there_is_an_appointment
        and_there_are_several_guiders
        when_they_attempt_to_reschedule_the_appointment
        and_select_ad_hoc_allocation
        and_reschedule_the_appointment
        then_the_appointment_is_rescheduled
      end
    end
  end

  scenario 'Rescheduling calendar respects resource manager grace period reduction' do
    given_the_user_is_a_resource_manager do
      travel_to '2021-05-11 13:00 UTC' do
        and_there_is_an_appointment
        and_there_are_available_slots_tomorrow
        when_they_attempt_to_reschedule_the_appointment
        then_they_see_the_available_slots_tomorrow
      end
    end
  end

  def and_there_are_available_slots_tomorrow
    create(:bookable_slot, guider: @appointment.guider, start_at: Time.zone.parse('2021-05-12 09:00'))
  end

  def then_they_see_the_available_slots_tomorrow
    @page.wait_until_slots_visible

    expect(@page).to have_slots(count: 1)
    expect(@page.slots.first).to have_text('09:00')
  end

  def and_there_is_an_appointment
    @appointment = create(:appointment)
  end

  def and_there_is_a_cancelled_appointment
    @appointment = create(:appointment, status: :cancelled_by_customer_sms)
  end

  def and_there_are_several_guiders
    @guider_one, @guider_two = create_list(:guider, 2)
  end

  def when_they_attempt_to_reschedule_the_appointment
    @page = Pages::RescheduleAppointment.new
    @page.load(id: @appointment.id)
  end

  def when_they_attempt_to_rebook_the_appointment
    @page = Pages::NewAppointment.new
    @page.load(query: { copy_from: @appointment.id })
  end

  def and_select_ad_hoc_allocation
    @page.availability_calendar_off.set(true)
  end

  def and_reschedule_the_appointment
    provide_scheduling_details
    @page.reschedule.click
  end

  def and_rebook_the_appointment
    provide_scheduling_details
    @page.preview_appointment.click

    @page = Pages::PreviewAppointment.new
    expect(@page).to be_displayed
    @page.confirm_appointment.click
  end

  def then_the_appointment_is_rescheduled
    @page = Pages::EditAppointment.new
    expect(@page).to be_displayed(id: @appointment.id)
    expect(@page).to have_flash_of_success

    expect(@page.guider).to have_text(@guider_two.name)
    expect(@page.date_time).to have_text('27 Dec 2017, 2:00pm - 3:10pm')
  end

  def then_the_appointment_is_rebooked
    @page = Pages::Search.new
    expect(@page).to be_displayed

    expect(Appointment.last).to have_attributes(
      guider_id: @guider_two.id,
      start_at: Time.zone.parse('2017-12-27 14:00 UTC'),
      end_at: Time.zone.parse('2017-12-27 15:10 UTC')
    )
  end

  def provide_scheduling_details
    @page.wait_until_ad_hoc_start_at_visible
    # bump it to the next hour
    @page.ad_hoc_start_at('2017-12-27 14:00')
    # change the guider
    @page.guider.select(@guider_two.name)
  end
end
