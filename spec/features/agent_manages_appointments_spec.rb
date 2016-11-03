# rubocop:disable Metrics/MethodLength
require 'rails_helper'

RSpec.feature 'Agent manages appointments' do
  let(:day) { BusinessDays.from_now(5) }

  scenario 'Agent creates appointments' do
    given_the_user_is_an_agent do
      and_there_is_a_guider_with_available_slots
      when_they_want_to_book_an_appointment
      and_they_fill_in_their_appointment_details
      then_that_appointment_is_created
      and_the_customer_gets_an_email_confirmation
    end
  end

  scenario 'Agent creates appointment without an email' do
    given_the_user_is_an_agent do
      and_there_is_a_guider_with_available_slots
      when_they_want_to_book_an_appointment
      and_they_fill_in_their_appointment_details_without_an_email
      then_the_customer_does_not_get_an_email_confirmation
    end
  end

  scenario 'Agent fails to create an appointment' do
    given_the_user_is_an_agent do
      and_there_is_a_guider_with_available_slots
      when_they_want_to_book_an_appointment
      and_all_slots_suddenly_become_unavailable
      and_they_fill_in_their_appointment_details
      then_they_are_told_that_the_slot_is_unavailable
    end
  end

  scenario 'Agent reschedules an appointment' do
    given_the_user_is_an_agent do
      and_there_is_a_guider_with_available_slots
      and_there_is_an_appointment
      and_they_want_to_reschedule_the_appointment
      when_they_reschedule_the_appointment
      then_the_appointment_is_rescheduled
      and_the_customer_gets_an_updated_email_confirmation
    end
  end

  scenario 'Agent reschedules an appointment without an email' do
    given_the_user_is_an_agent do
      and_there_is_a_guider_with_available_slots
      and_there_is_an_appointment_without_an_email
      and_they_want_to_reschedule_the_appointment
      when_they_reschedule_the_appointment
      then_the_customer_does_not_get_an_updated_email_confirmation
    end
  end

  scenario 'Agent fails to reschedule an appointment' do
    given_the_user_is_an_agent do
      and_there_is_a_guider_with_available_slots
      and_there_is_an_appointment
      and_they_want_to_reschedule_the_appointment
      and_all_slots_suddenly_become_unavailable
      when_they_reschedule_the_appointment
      then_they_are_told_that_the_slot_is_unavailable
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
  def fill_in_appointment_details(options = {})
    @page.first_name.set 'Some'
    @page.last_name.set 'Person'
    @page.email.set options[:email] || 'email@example.org'
    @page.phone.set '0000000'
    @page.mobile.set '1111111'
    @page.memorable_word.set 'lozenge'
    @page.notes.set 'something'
    @page.date_of_birth_day.set '23'
    @page.date_of_birth_month.set '10'
    @page.date_of_birth_year.set '1950'
    @page.opt_out_of_market_research.set true
    @page.start_at.set day.change(hour: 9, min: 30).to_s
    @page.end_at.set day.change(hour: 10, min: 40).to_s

    @page.save.click
  end

  def and_they_fill_in_their_appointment_details
    fill_in_appointment_details
  end

  def and_they_fill_in_their_appointment_details_without_an_email
    fill_in_appointment_details email: ''
  end

  def then_that_appointment_is_created
    @guider.reload
    expect(Appointment.count).to eq 1
    appointment = Appointment.first

    expect(appointment.agent).to eq current_user
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
    expect(appointment.start_at).to eq day.change(hour: 9, min: 30).to_s
    expect(appointment.status).to eq 'pending'
    expect(appointment.end_at).to eq day.change(hour: 10, min: 40).to_s
  end

  def and_the_customer_gets_an_email_confirmation
    deliveries = ActionMailer::Base.deliveries
    expect(deliveries.count).to eq 1
    expect(deliveries.first.subject).to eq 'Your Pension Wise Appointment'
  end

  def and_the_customer_gets_an_updated_email_confirmation
    deliveries = ActionMailer::Base.deliveries
    expect(deliveries.count).to eq 1
    expect(deliveries.first.subject).to eq 'Your Pension Wise Appointment'
    expect(deliveries.first.body.encoded).to include 'Your appointment details were updated'
  end

  def then_the_customer_does_not_get_an_email_confirmation
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  def then_the_customer_does_not_get_an_updated_email_confirmation
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  def when_they_want_to_book_an_appointment
    @page = Pages::NewAppointment.new.tap(&:load)
  end

  def and_there_is_an_appointment
    @appointment = create(:appointment)
  end

  def and_there_is_an_appointment_without_an_email
    @appointment = create(:appointment, email: nil)
  end

  def and_they_want_to_reschedule_the_appointment
    @page = Pages::RescheduleAppointment.new
    @page.load(id: @appointment.id)
  end

  def when_they_reschedule_the_appointment
    @page.start_at.set day.change(hour: 16, min: 15).to_s
    @page.end_at.set day.change(hour: 17, min: 15).to_s
    @page.reschedule.click
  end

  def then_the_appointment_is_rescheduled
    appointment = Appointment.first
    expect(appointment.start_at).to eq day.change(hour: 16, min: 15).to_s
    expect(appointment.end_at).to eq day.change(hour: 17, min: 15).to_s
  end

  def and_all_slots_suddenly_become_unavailable
    BookableSlot.delete_all
  end

  def then_they_are_told_that_the_slot_is_unavailable
    expect(@page).to have_slot_unavailable_message
  end
end
