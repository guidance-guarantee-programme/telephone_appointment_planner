require 'rails_helper'

RSpec.feature 'Editing appointments and permissions' do
  scenario 'TP agent can edit other’s appointments' do
    given_the_user_is_an_agent do # TP agent
      and_another_organisations_appointment_exists
      when_they_edit_the_appointment
      they_see_the_appointment
    end
  end

  scenario 'Other people can’t edit other’s appointments' do
    given_the_user_is_a_resource_manager(organisation: :cas) do
      and_another_organisations_appointment_exists
      when_they_edit_the_appointment
      then_they_do_not_see_the_appointment
    end
  end

  def and_another_organisations_appointment_exists
    @appointment = create(:appointment) # TPAS guider
  end

  def when_they_edit_the_appointment
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
  end

  def they_see_the_appointment
    expect(@page).to be_displayed
    expect(@page).to have_no_permissions_warning
  end

  def then_they_do_not_see_the_appointment
    expect(@page).to be_displayed
    expect(@page).to have_permissions_warning
  end
end
