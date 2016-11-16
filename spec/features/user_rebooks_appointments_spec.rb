require 'rails_helper'

RSpec.feature 'Agent rebooks appointments' do
  scenario 'Agent rebooks an appointment' do
    given_the_user_is_an_agent do
      and_there_is_an_appointment
      and_they_rebook_an_appointment
      then_the_details_are_copied_over
      and_the_start_and_end_date_are_not_copied_over
    end
  end

  def and_there_is_an_appointment
    @appointment = create(:appointment)
  end

  def and_they_rebook_an_appointment
    @page = Pages::Search.new.tap(&:load)
    @page.rebook.click
    @page = Pages::NewAppointment.new
    expect(@page).to be_displayed
  end

  def then_the_details_are_copied_over # rubocop:disable Metrics/MethodLength
    expect(@page.first_name.value).to eq @appointment.first_name
    expect(@page.last_name.value).to eq @appointment.last_name
    expect(@page.email.value).to eq @appointment.email
    expect(@page.phone.value).to eq @appointment.phone
    expect(@page.mobile.value).to eq @appointment.mobile
    expect(@page.date_of_birth_day.value).to eq @appointment.date_of_birth.day.to_s
    expect(@page.date_of_birth_month.value).to eq @appointment.date_of_birth.month.to_s
    expect(@page.date_of_birth_year.value).to eq @appointment.date_of_birth.year.to_s
    expect(@page.memorable_word.value).to eq @appointment.memorable_word
    expect(@page.notes.value).to eq @appointment.notes
    expect(@page.opt_out_of_market_research.checked?).to eq @appointment.opt_out_of_market_research?
  end

  def and_the_start_and_end_date_are_not_copied_over
    expect(@page.start_at.value).to be_blank
    expect(@page.end_at.value).to be_blank
  end
end
