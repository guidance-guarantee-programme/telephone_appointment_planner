# rubocop:disable Metrics/MethodLength
require 'rails_helper'

RSpec.feature 'Agent creates appointments' do
  scenario 'Creates an appointment' do
    given_the_user_is_an_agent do
      and_there_is_a_guider_with_available_slots
      when_they_create_a_new_appointment
      then_that_appointment_is_stored
    end
  end

  def and_there_is_a_guider_with_available_slots
    @guider = create(:guider)
    @slot = build(
      :slot,
      day_of_week: Time.zone.now.wday,
      start_hour: 9,
      start_minute: 30,
      end_hour: 10,
      end_minute: 40
    )
    @schedule = @guider.schedules.build(
      start_at: Time.zone.now.beginning_of_day,
      slots: [@slot]
    )
    @schedule.save!
    BookableSlot.generate_for_six_weeks
  end

  # rubocop:disable Metrics/AbcSize
  def when_they_create_a_new_appointment
    @page = Pages::NewAppointment.new
    @page.load

    @page.first_name.set 'Some'
    @page.last_name.set 'Person'
    @page.email.set 'email@example.org'
    @page.phone.set '0000000'
    @page.mobile.set '1111111'
    @page.year_of_birth.set '1891'
    @page.memorable_word.set 'lozenge'
    @page.notes.set 'something'
    @page.opt_out_of_market_research.set true
    @page.where_did_you_hear_about_pension_wise.select 'Radio advert'
    @page.start_at.set Time.zone.now.change(hour: 9, min: 30).to_s
    @page.end_at.set Time.zone.now.change(hour: 10, min: 40).to_s

    @page.save.click
  end

  def then_that_appointment_is_stored
    @guider.reload
    expect(Appointment.count).to eq 1
    appointment = Appointment.first

    expect(appointment.guider).to eq @guider
    expect(appointment.first_name).to eq 'Some'
    expect(appointment.last_name).to eq 'Person'
    expect(appointment.email).to eq 'email@example.org'
    expect(appointment.phone).to eq '0000000'
    expect(appointment.mobile).to eq '1111111'
    expect(appointment.year_of_birth).to eq '1891'
    expect(appointment.memorable_word).to eq 'lozenge'
    expect(appointment.notes).to eq 'something'
    expect(appointment.opt_out_of_market_research).to eq true
    expect(appointment.where_did_you_hear_about_pension_wise).to eq 'Radio advert'
    expect(appointment.start_at).to eq Time.zone.now.change(hour: 9, min: 30).to_s
    expect(appointment.end_at).to eq Time.zone.now.change(hour: 10, min: 40).to_s
  end
end
