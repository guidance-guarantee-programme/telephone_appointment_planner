# rubocop:disable Metrics/MethodLength
require 'rails_helper'

RSpec.feature 'Agent manages appointments' do
  let(:day) { BusinessDays.from_now(5) }

  describe 'Agent creates appointments' do
    scenario 'Customer is not eligible for an appointment' do
      given_the_user_is_an_agent do
        when_they_want_to_book_an_appointment
        and_the_customer_is_ineligible_for_an_appointment
        when_they_try_to_create_an_appointment
        then_they_are_told_that_the_customer_is_ineligible
      end
    end

    scenario 'Customer is eligible for an appointment' do
      given_the_user_is_an_agent do
        and_there_is_a_guider_with_available_slots
        when_they_want_to_book_an_appointment
        and_the_customer_is_eligible_for_an_appointment
        when_they_try_to_create_an_appointment
        and_they_fill_in_their_appointment_details
        then_that_appointment_is_created
      end
    end
  end

  scenario 'Agent reschedules an appointment' do
    given_the_user_is_an_agent do
      and_there_is_a_guider_with_available_slots
      and_there_is_an_appointment
      when_the_agent_reschedules_the_appointment
      then_the_appointment_is_rescheduled
    end
  end

  def and_there_is_a_guider_with_available_slots
    @guider = create(:guider)
    slots = [
      build(:nine_thirty_slot, day_of_week: day.wday),
      build(:four_fifteen_slot, day_of_week: day.wday)
    ]
    @schedule = @guider.schedules.build(
      start_at: day.beginning_of_day,
      slots: slots
    )
    @schedule.save!
    BookableSlot.generate_for_guider(@guider)
  end

  # rubocop:disable Metrics/AbcSize
  def and_they_fill_in_their_appointment_details
    @page = Pages::NewAppointment.new

    @page.email.set 'email@example.org'
    @page.phone.set '0000000'
    @page.mobile.set '1111111'
    @page.memorable_word.set 'lozenge'
    @page.notes.set 'something'
    @page.opt_out_of_market_research.set true
    @page.where_did_you_hear_about_pension_wise.select 'Radio advert'
    @page.who_is_your_pension_provider.select 'Scottish Widows'
    @page.start_at.set day.change(hour: 9, min: 30).to_s
    @page.end_at.set day.change(hour: 10, min: 40).to_s

    @page.save.click
  end

  def then_that_appointment_is_created
    @guider.reload
    expect(Appointment.count).to eq 1
    appointment = Appointment.first

    expect(appointment.guider).to eq @guider
    expect(appointment.first_name).to eq 'Some'
    expect(appointment.last_name).to eq 'Person'
    expect(appointment.email).to eq 'email@example.org'
    expect(appointment.phone).to eq '0000000'
    expect(appointment.mobile).to eq '1111111'
    expect(appointment.date_of_birth.to_s).to eq '1950-10-23'
    expect(appointment.memorable_word).to eq 'lozenge'
    expect(appointment.notes).to eq 'something'
    expect(appointment.opt_out_of_market_research).to eq true
    expect(appointment.where_did_you_hear_about_pension_wise).to eq 'Radio advert'
    expect(appointment.who_is_your_pension_provider).to eq 'Scottish Widows'
    expect(appointment.start_at).to eq day.change(hour: 9, min: 30).to_s
    expect(appointment.status).to eq 'pending'
    expect(appointment.end_at).to eq day.change(hour: 10, min: 40).to_s
  end

  def when_they_want_to_book_an_appointment
    @page = Pages::NewAppointmentAttempt.new
    @page.load
  end

  def and_the_customer_is_ineligible_for_an_appointment
    @page.first_name.set 'First'
    @page.last_name.set 'Last'
    @page.date_of_birth_day.set '23'
    @page.date_of_birth_month.set '10'
    @page.date_of_birth_year.set '1983'
    @page.defined_contribution_pot.set false
  end

  def and_the_customer_is_eligible_for_an_appointment
    @page.first_name.set 'Some'
    @page.last_name.set 'Person'
    @page.date_of_birth_day.set '23'
    @page.date_of_birth_month.set '10'
    @page.date_of_birth_year.set '1950'
    @page.defined_contribution_pot.set true
  end

  def when_they_try_to_create_an_appointment
    @page.next.click
  end

  def then_they_are_told_that_the_customer_is_ineligible
    expect(@page).to have_ineligible_message
  end

  def and_there_is_an_appointment
    @appointment = create(:appointment)
  end

  def when_the_agent_reschedules_the_appointment
    @page = Pages::RescheduleAppointment.new
    @page.load(id: @appointment.id)
    @page.start_at.set day.change(hour: 16, min: 15).to_s
    @page.end_at.set day.change(hour: 17, min: 15).to_s
    @page.reschedule.click
  end

  def then_the_appointment_is_rescheduled
    appointment = Appointment.first
    expect(appointment.start_at).to eq day.change(hour: 16, min: 15).to_s
    expect(appointment.end_at).to eq day.change(hour: 17, min: 15).to_s
  end
end
