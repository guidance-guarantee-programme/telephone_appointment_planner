require 'rails_helper'

RSpec.feature 'Cancellation via for correct primary statuses' do
  scenario 'Is hidden for the right primary/secondary statuses', js: true do
    given_the_user_is_a_resource_manager do
      when_they_edit_an_existing_appointment
      then_they_see_the_correct_behaviours_when_modifying_statuses
    end
  end

  def when_they_edit_an_existing_appointment
    @appointment = create(:appointment)

    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
  end

  def then_they_see_the_correct_behaviours_when_modifying_statuses
    expect(@page).to have_no_cancelled_via_phone

    @page.status.select 'Cancelled By Customer'
    @page.wait_until_secondary_status_options_visible
    @page.secondary_status.select 'Cancelled prior to appointment'
    @page.wait_until_cancelled_via_phone_visible

    @page.status.select 'Pending'
    @page.wait_until_secondary_status_options_invisible
    @page.wait_until_cancelled_via_phone_invisible
  end
end
