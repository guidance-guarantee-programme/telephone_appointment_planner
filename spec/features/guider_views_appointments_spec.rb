# rubocop:disable Metrics/AbcSize
require 'rails_helper'

RSpec.feature 'Guider views appointments' do
  scenario 'Guider views their own appointments', js: true do
    given_the_user_is_a_guider do
      and_there_are_appointments_for_multiple_guiders
      travel_to @appointment.start_at do
        when_they_view_their_calendar
        then_they_see_the_appointment_for_today
        when_they_advance_a_working_day
        then_they_see_the_appointment_for_that_day
        and_they_can_edit_the_appointment
      end
    end
  end

  def and_there_are_appointments_for_multiple_guiders
    # this would appear 'today'
    @appointment = create(:appointment, guider: current_user)
    # this would appear 'tomorrow'
    @tomorrow = create(:appointment, guider: current_user, start_at: BusinessDays.from_now(4))
    # this won't appear for the current user
    create(:appointment)
  end

  def when_they_view_their_calendar
    @page = Pages::Calendar.new.tap(&:load)
  end

  def then_they_see_the_appointment_for_today
    @page.wait_for_appointments
    expect(@page).to have_appointments(count: 1)

    @page.appointments.first do |appointment|
      expect(appointment.title.text).to include(@appointment.first_name)
      expect(appointment.title.text).to include(@appointment.last_name)
      expect(appointment.title.text).to include(@appointment.memorable_word)
      expect(appointment.title.text).to include(@appointment.phone)
    end
  end

  def when_they_advance_a_working_day
    @page.next_working_day.click
  end

  def then_they_see_the_appointment_for_that_day
    @page.wait_for_appointments
    expect(@page).to have_appointments(count: 1)

    expect(@page.appointments.first.text).to include(@tomorrow.first_name)
  end

  def and_they_can_edit_the_appointment
    expect(@page.appointments.first.root_element['href']).to end_with(edit_appointment_path(@tomorrow))
  end
end
