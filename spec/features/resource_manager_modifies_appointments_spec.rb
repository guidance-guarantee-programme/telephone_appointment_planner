# rubocop:disable Metrics/AbcSize
require 'rails_helper'

RSpec.feature 'Resource manager modifies appointments' do
  scenario 'Rescheduling an appointment', js: true do
    given_the_user_is_a_resource_manager do
      and_there_are_appointments_for_multiple_guiders
      travel_to @appointment.start_at do
        when_they_view_the_appointments
        then_they_see_appointments_for_multiple_guiders
        when_they_reschedule_an_appointment
        and_commit_their_modifications
        then_the_appointment_is_modified
      end
    end
  end

  def and_there_are_appointments_for_multiple_guiders
    @ben = create(:guider, name: 'Ben Lovell')
    @jan = create(:guider, name: 'Jan Schwifty')

    @appointment = create(:appointment, guider: @ben)
    @other_appointment = create(:appointment, guider: @jan)
  end

  def when_they_view_the_appointments
    @page = Pages::ResourceCalendar.new.tap(&:load)
    expect(@page).to be_displayed
  end

  def then_they_see_appointments_for_multiple_guiders
    @page.wait_for_guiders
    expect(@page).to have_guiders(count: 2)
    expect(@page.guiders.first).to have_text('Ben Lovell')

    @page.wait_for_appointments
    expect(@page).to have_appointments(count: 2)
  end

  def when_they_reschedule_an_appointment
    @page.reschedule(@page.appointments.first, hours: 8, minutes: 30)
  end

  def and_commit_their_modifications
    @page.wait_until_action_panel_visible
    @page.action_panel.save.click
  end

  def then_the_appointment_is_modified
    @appointment.reload

    expect(@appointment.start_at.hour).to eq(8)
    expect(@appointment.start_at.min).to eq(30)

    expect(@appointment.end_at.hour).to eq(9)
    expect(@appointment.end_at.min).to eq(30)
  end
end
