require 'rails_helper'

RSpec.feature 'Resource manager processes an appointment' do
  scenario 'Processing is not visible to TPAS members' do
    given_the_user_is_a_resource_manager do
      and_an_appointment_exists_for(:tpas)
      when_they_edit_the_appointment
      then_they_do_not_see_the_process_button
    end
  end

  scenario 'Another organisation member processes their appointment' do
    given_the_user_is_a_resource_manager(organisation: :cas) do
      and_an_appointment_exists_for(:cas)
      when_they_edit_the_appointment
      and_they_process_the_appointment
      then_the_appointment_is_processed
      and_the_process_button_is_hidden
      and_an_activity_is_logged
    end
  end

  scenario 'Viewing processed/unprocessed appointments in search results' do
    given_the_user_is_a_resource_manager(organisation: :cas) do
      and_an_appointment_exists_for(:cas)
      and_a_processed_appointment_exists_for(:cas)
      when_they_view_the_appointments
      then_one_appointment_is_processed
      and_the_other_is_not_processed
    end
  end

  def and_a_processed_appointment_exists_for(organisation)
    create(:appointment, :processed, organisation: organisation)
  end

  def when_they_view_the_appointments
    @page = Pages::Search.new
    @page.load
  end

  def then_one_appointment_is_processed
    expect(@page).to have_processed(count: 1)
  end

  def and_the_other_is_not_processed
    expect(@page).to have_results(count: 2)
  end

  def and_an_appointment_exists_for(organisation)
    @appointment = create(:appointment, organisation: organisation)
  end

  def when_they_edit_the_appointment
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
  end

  def then_they_do_not_see_the_process_button
    expect(@page).to have_no_process
  end

  def and_they_process_the_appointment
    @page.process.click
  end

  def then_the_appointment_is_processed
    expect(@page).to have_flash_of_success
  end

  def and_the_process_button_is_hidden
    expect(@page).to have_no_process
  end

  def and_an_activity_is_logged
    expect(@page.activity_feed).to have_text('processed this appointment')
  end
end
