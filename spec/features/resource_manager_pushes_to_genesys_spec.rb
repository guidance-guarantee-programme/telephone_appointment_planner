require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Resource manager pushes an appointment to Genesys' do
  before do
    allow(PushGenesysAppointmentJob).to receive(:perform_later)
  end

  scenario 'Successfully pushing a valid appointment' do
    given_the_user_is_a_resource_manager do
      and_a_genesys_pushable_appointment_exists
      when_they_edit_the_appointment
      and_force_push_to_genesys
      then_the_push_job_is_enqueued
      and_they_see_the_success_message
    end
  end

  def and_a_genesys_pushable_appointment_exists
    @appointment = create(:appointment, :genesys_guider)
  end

  def when_they_edit_the_appointment
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
  end

  def and_force_push_to_genesys
    @page.push_to_genesys.click
  end

  def then_the_push_job_is_enqueued
    expect(PushGenesysAppointmentJob).to have_received(:perform_later).with(@appointment)
  end

  def and_they_see_the_success_message
    expect(@page).to have_flash_of_success
  end
end
# rubocop:enable Metrics/BlockLength
