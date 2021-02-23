require 'rails_helper'

RSpec.feature 'Guider views duplicate appointments' do
  scenario 'Viewing an appointment with duplicates' do
    given_the_user_is_a_guider do
      and_an_appointment_with_duplicates_exists
      when_they_view_the_duplicates
      then_they_see_the_required_information
    end
  end

  def and_an_appointment_with_duplicates_exists
    @appointment = create_list(:appointment, 2, first_name: 'Bob', last_name: 'McDuplicated').first
  end

  def when_they_view_the_duplicates
    @page = Pages::DuplicateAppointments.new
    @page.load(id: @appointment.id)
  end

  def then_they_see_the_required_information
    expect(@page).to be_displayed

    expect(@page).to have_duplicates(count: 1)
  end
end
