# rubocop:disable Metrics/AbcSize
require 'rails_helper'

RSpec.feature 'Guider views appointments' do
  scenario 'Guider views their own appointments', js: true do
    given_the_user_is_both_guider_and_manager do
      and_there_are_appointments_for_multiple_guiders
      and_the_user_has_a_schedule
      travel_to @appointment.start_at do
        when_they_view_their_calendar
        then_they_see_the_appointment_for_today
        and_they_see_their_schedule_for_today
        when_they_advance_a_working_day
        then_they_see_the_appointment_for_that_day
        and_they_see_their_schedule_for_tomorrow
        and_they_can_edit_the_appointment
      end
    end
  end

  scenario 'Guider views all appointments', js: true do
    given_the_user_is_a_guider do
      and_there_are_appointments_for_multiple_guiders
      travel_to @appointment.start_at do
        when_they_view_the_company_calendar
        then_they_see_the_appointments_for_today
        when_they_advance_a_working_day
        then_they_see_the_appointments_for_that_day
        and_they_can_edit_an_appointment
      end
    end
  end

  def and_there_are_appointments_for_multiple_guiders
    # this would appear 'today'
    @appointment = create(:appointment, guider: current_user)
    # this would appear 'tomorrow'
    @appointment_tomorrow = create(
      :appointment,
      guider: current_user,
      start_at: BusinessDays.from_now(4).at_midday
    )
    # this won't appear for the current user
    create(:appointment)
  end

  # rubocop:disable Metrics/MethodLength
  def and_the_user_has_a_schedule
    today    = BusinessDays.from_now(3).beginning_of_day
    tomorrow = BusinessDays.from_now(4).beginning_of_day
    # this would appear 'today'
    @bookable_slots = [
      current_user.bookable_slots.create(
        start_at: today.change(hour: 14),
        end_at: today.change(hour: 15)
      ),
      # this would appear 'tomorrow'
      current_user.bookable_slots.create(
        start_at: tomorrow.change(hour: 15),
        end_at: tomorrow.change(hour: 16)
      )
    ]
  end
  # rubocop:enable Metrics/MethodLength

  def when_they_view_their_calendar
    @page = Pages::Calendar.new.tap(&:load)
  end

  def when_they_view_the_company_calendar
    @page = Pages::CompanyCalendar.new.tap(&:load)
  end

  def then_they_see_the_appointment_for_today
    @page.wait_until_appointments_visible
    expect(@page).to have_appointments(count: 1)

    @page.appointments.first.tap do |appointment|
      expect(appointment.title.text).to include(@appointment.first_name)
      expect(appointment.title.text).to include(@appointment.last_name)
      expect(appointment.title.text).to include(@appointment.memorable_word)
      expect(appointment.title.text).to include(@appointment.phone)
    end
  end

  def and_they_see_their_schedule_for_today
    event = @page.calendar.background_events.first
    expect(Time.zone.parse(event[:start])).to eq @bookable_slots.first.start_at
    expect(Time.zone.parse(event[:end])).to eq @bookable_slots.first.end_at
  end

  def then_they_see_the_appointments_for_today
    @page.wait_until_appointments_visible
    expect(@page).to have_appointments(count: 1)

    actual = @page.appointments.first['id']

    expect(actual).to eq(@appointment.id.to_s)
  end

  def when_they_advance_a_working_day
    @page.next_working_day.click
  end

  def then_they_see_the_appointment_for_that_day
    @page.wait_until_appointments_visible
    expect(@page).to have_appointments(count: 1)

    expect(@page.appointments.first.text).to include(@appointment_tomorrow.first_name)
  end

  def and_they_see_their_schedule_for_tomorrow
    event = @page.calendar.background_events.first
    expect(Time.zone.parse(event[:start])).to eq @bookable_slots.second.start_at
    expect(Time.zone.parse(event[:end])).to eq @bookable_slots.second.end_at
  end

  def then_they_see_the_appointments_for_that_day
    @page.wait_until_appointments_visible
    expect(@page).to have_appointments(count: 1)

    actual = @page.appointments.first['id']

    expect(actual).to eq(@appointment_tomorrow.id.to_s)
  end

  def and_they_can_edit_the_appointment
    expect(@page.appointments.first.root_element['href']).to end_with(edit_appointment_path(@appointment_tomorrow))
  end

  def and_they_can_edit_an_appointment
    expect(@page.appointments.first['href']).to end_with(edit_appointment_path(@appointment_tomorrow))
  end
end
