# rubocop:disable Metrics/AbcSize
require 'rails_helper'

RSpec.feature 'Guider edits an appointment' do
  scenario 'Successfully editing an appointment' do
    given_the_user_is_a_guider do
      and_they_have_an_appointment
      when_they_attempt_to_edit_the_appointment
      then_they_see_the_existing_details
      when_they_modify_the_appointment
      then_the_appointment_is_changed
    end
  end

  def and_they_have_an_appointment
    @appointment = create(:appointment, guider: current_user)
  end

  def when_they_attempt_to_edit_the_appointment
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
  end

  def then_they_see_the_existing_details
    expect(@page.first_name.value).to eq(@appointment.first_name)
    expect(@page.last_name.value).to eq(@appointment.last_name)
    expect(@page.email.value).to eq(@appointment.email)
    expect(@page.phone.value).to eq(@appointment.phone)
    expect(@page.mobile.value).to eq(@appointment.mobile)
    expect(@page.memorable_word.value).to eq(@appointment.memorable_word)
    expect(@page.notes.value).to eq(@appointment.notes)
    expect(@page.opt_out_of_market_research.value).to eq('1')
    expect(@page.where_did_you_hear_about_pension_wise.value).to eq(@appointment.where_did_you_hear_about_pension_wise)
    expect(@page.who_is_your_pension_provider.value).to eq(@appointment.who_is_your_pension_provider)
  end

  def when_they_modify_the_appointment
    @page.first_name.set 'Rick'
    @page.submit.click
  end

  def then_the_appointment_is_changed
    expect(@appointment.reload.first_name).to eq('Rick')
  end
end
