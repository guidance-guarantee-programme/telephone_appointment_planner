require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Resource manager reallocates an appointment', js: true do
  scenario 'Successfully reallocating' do
    given_the_user_is_a_resource_manager(organisation: :tpas) do
      and_a_reallocatable_appointment_exists
      and_another_guider_exists
      when_the_appointment_is_reallocated
      then_the_appointment_is_assigned_to_the_correct_guider
    end
  end

  def and_a_reallocatable_appointment_exists
    @appointment = create(:appointment)
  end

  def and_another_guider_exists
    @guider = create(:guider)
  end

  def when_the_appointment_is_reallocated
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
    @page.reallocate.click

    @page = Pages::ReallocateAppointment.new
    expect(@page).to be_displayed
    @page.guider.select(@guider.name)
    @page.unplanned_absence.set(true)
    @page.reallocate.click

    @page = Pages::Allocations.new
    expect(@page).to be_displayed
    expect(@page).to have_flash_of_success
  end

  def then_the_appointment_is_assigned_to_the_correct_guider
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)

    expect(@page.guider).to have_text(@guider.name)
  end
end
# rubocop:enable Metrics/BlockLength
