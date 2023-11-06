require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Breadcrumb' do
  describe 'Edit appointment after viewing allocations' do
    it 'shows the correct breadcrumb link' do
      given_the_user_is_a_guider do
        and_an_appointment_exists
        and_they_view_the_allocations
        and_they_edit_the_appointment
        then_they_see_a_breadcrumb_pointing_to_allocations
      end
    end
  end

  describe 'Navigates directly to edit appointments page' do
    it 'shows the correct breadcrumb link' do
      given_the_user_is_a_guider do
        and_an_appointment_exists
        and_they_edit_the_appointment
        then_they_see_a_breadcrumb_pointing_to_search
      end
    end
  end

  describe 'Edit appointment after viewing appointments search' do
    it 'shows the correct breadcrumb link' do
      given_the_user_is_a_guider do
        and_an_appointment_exists
        and_they_search_appointments
        and_they_edit_the_appointment
        then_they_see_a_breadcrumb_pointing_to_search
      end
    end
  end

  describe 'Edit appointment after viewing company calendar' do
    it 'shows the correct breadcrumb link' do
      given_the_user_is_a_guider do
        and_an_appointment_exists
        and_they_view_the_company_calendar
        and_they_edit_the_appointment
        then_they_see_a_breadcrumb_pointing_to_the_company_calendar
      end
    end
  end

  describe 'Edit appointment after viewing my appointments' do
    it 'shows the correct breadcrumb link' do
      given_the_user_is_a_guider do
        and_an_appointment_exists
        and_they_view_their_appointments
        and_they_edit_the_appointment
        then_they_see_a_breadcrumb_pointing_to_their_appointments
      end
    end
  end

  describe 'Edit appointment after viewing my activity' do
    it 'shows the correct breadcrumb link' do
      given_the_user_is_a_guider do
        and_an_appointment_exists
        and_they_view_their_activity
        and_they_edit_the_appointment
        then_they_see_a_breadcrumb_pointing_to_their_activity
      end
    end
  end

  def and_an_appointment_exists
    @appointment = create(:appointment)
  end

  def and_they_edit_the_appointment
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
  end

  def and_they_search_appointments
    Pages::Search.new.tap(&:load)
  end

  def and_they_view_the_company_calendar
    Pages::CompanyCalendar.new.tap(&:load)
  end

  def and_they_view_their_appointments
    Pages::MyAppointments.new.tap(&:load)
  end

  def and_they_view_their_activity
    Pages::Activities.new.tap(&:load)
  end

  def and_they_view_the_allocations
    Pages::Allocations.new.tap(&:load)
  end

  def then_they_see_a_breadcrumb_pointing_to_allocations
    expect(@page.breadcrumb_links.second).to eq(
      'Allocations' => allocations_path
    )
  end

  def then_they_see_a_breadcrumb_pointing_to_search
    expect(@page.breadcrumb_links.second).to eq(
      'Appointment search' => search_appointments_path
    )
  end

  def then_they_see_a_breadcrumb_pointing_to_the_company_calendar
    expect(@page.breadcrumb_links.second).to eq(
      'Company appointments' => company_calendar_path
    )
  end

  def then_they_see_a_breadcrumb_pointing_to_their_appointments
    expect(@page.breadcrumb_links.second).to eq(
      'My appointments' => my_appointments_path
    )
  end

  def then_they_see_a_breadcrumb_pointing_to_their_activity
    expect(@page.breadcrumb_links.second).to eq(
      'My activity' => activities_path
    )
  end
end
# rubocop:enable Metrics/BlockLength
