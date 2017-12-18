require 'rails_helper'

RSpec.feature 'Resource manager reschedules an appointment', js: true do
  scenario 'Rescheduling with ad-hoc allocation' do
    given_the_user_is_a_resource_manager do
      travel_to '2017-12-27 13:00 UTC' do
        and_there_is_an_appointment
        and_there_are_several_guiders
        when_they_attempt_to_reschedule_the_appointment
        and_select_ad_hoc_allocation
        and_reschedule_the_appointment
        then_the_appointment_is_rescheduled
      end
    end
  end

  def and_there_is_an_appointment
    @appointment = create(:appointment)
  end

  def and_there_are_several_guiders
    @guider_one, @guider_two = create_list(:guider, 2)
  end

  def when_they_attempt_to_reschedule_the_appointment
    @page = Pages::RescheduleAppointment.new
    @page.load(id: @appointment.id)
  end

  def and_select_ad_hoc_allocation
    @page.availability_calendar_off.set(true)
  end

  def and_reschedule_the_appointment
    @page.wait_until_ad_hoc_start_at_visible
    # bump it to the next hour
    @page.ad_hoc_start_at('2017-12-27 14:00')
    # change the guider
    @page.guider.select(@guider_two.name)
    @page.reschedule.click
  end

  def then_the_appointment_is_rescheduled
    @page = Pages::EditAppointment.new
    expect(@page).to be_displayed(id: @appointment.id)
    expect(@page).to have_flash_of_success

    expect(@page.guider).to have_text(@guider_two.name)
    expect(@page.date_time).to have_text('27 Dec 2017, 2:00pm - 3:10pm')
  end
end
