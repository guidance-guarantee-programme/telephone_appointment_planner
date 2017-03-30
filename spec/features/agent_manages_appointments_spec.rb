require 'rails_helper'

RSpec.feature 'Agent manages appointments' do
  let(:day) { BusinessDays.from_now(5) }

  scenario 'Agent creates appointments' do
    given_the_user_is_an_agent do
      and_there_is_a_guider_with_available_slots
      when_they_want_to_book_an_appointment
      and_they_fill_in_their_appointment_details
      then_they_see_a_preview_of_the_appointment
      when_they_accept_the_appointment_preview
      then_that_appointment_is_created
      and_the_customer_gets_an_email_confirmation
    end
  end

  scenario 'Agents goes back to edit appointment when previewing' do
    given_the_user_is_an_agent do
      and_there_is_a_guider_with_available_slots
      when_they_want_to_book_an_appointment
      and_they_fill_in_their_appointment_details
      when_they_go_back_to_edit_their_appointment
      and_they_change_some_details
      when_they_accept_the_appointment_preview
      then_the_appointment_is_created_with_the_changed_details
    end
  end

  scenario 'Agent creates appointment without an email' do
    given_the_user_is_an_agent do
      and_there_is_a_guider_with_available_slots
      when_they_want_to_book_an_appointment
      and_they_fill_in_their_appointment_details_without_an_email
      when_they_accept_the_appointment_preview
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

  scenario 'Agent modifies an appointment' do
    given_the_user_is_an_agent do
      and_there_is_a_guider_with_available_slots
      and_there_is_an_appointment
      when_they_change_the_appointment_first_name
      then_the_appointments_first_name_is_changed
      and_the_customer_gets_an_updated_email_confirmation
    end
  end

  scenario 'Agent modifies an appointment without an email' do
    given_the_user_is_an_agent do
      and_there_is_a_guider_with_available_slots
      and_there_is_an_appointment_without_an_email
      when_they_change_the_appointment_first_name
      then_the_appointments_first_name_is_changed
      then_the_customer_does_not_get_an_updated_email_confirmation
    end
  end

  scenario 'Agent cancels an appointment' do
    given_the_user_is_an_agent do
      and_there_is_an_appointment
      when_they_cancel_the_appointment
      then_the_customer_gets_a_cancellation_email
    end
  end

  scenario 'Agent cancels an appointment by order of the customer' do
    given_the_user_is_an_agent do
      and_there_is_an_appointment
      when_they_cancel_the_appointment_by_order_of_the_customer
      then_the_customer_gets_a_cancellation_email
    end
  end

  scenario 'Agent changes appointment status' do
    given_the_user_is_an_agent do
      and_there_is_an_appointment
      and_they_change_the_appointment_status
      then_the_customer_does_not_get_a_cancellation_email
    end
  end

  scenario 'Agent marks an appointment as no-show' do
    given_the_user_is_an_agent do
      and_there_is_an_appointment
      when_they_mark_the_appointment_as_missed
      then_the_customer_gets_a_missed_appointment_email
    end
  end

  scenario 'Agent sees that the appointment was imported' do
    given_the_user_is_an_agent do
      and_there_is_an_imported_appointment
      when_they_edit_the_appointment
      then_they_see_that_the_appointment_was_imported
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
    BookableSlot.generate_for_six_weeks
  end

  def fill_in_appointment_details(options = {})
    @page.date_of_birth_day.set '23'
    @page.date_of_birth_month.set '10'
    @page.date_of_birth_year.set '1950'
    @page.first_name.set 'Some'
    @page.last_name.set 'Person'
    @page.email.set options[:email] || 'email@example.org'
    @page.phone.set '0000000'
    @page.mobile.set '1111111'
    @page.memorable_word.set 'lozenge'
    @page.notes.set 'something'
    @page.opt_out_of_market_research.set true
    @page.start_at.set day.change(hour: 9, min: 30).to_s
    @page.end_at.set day.change(hour: 10, min: 40).to_s
    @page.type_of_appointment_standard.set true

    @page.preview_appointment.click
  end

  def and_they_fill_in_their_appointment_details
    fill_in_appointment_details
  end

  def then_they_see_a_preview_of_the_appointment
    @page = Pages::PreviewAppointment.new
    expect(@page).to be_displayed

    expect(@page.preview).to have_content "#{day.to_date.to_s(:govuk_date)} 9:30am"
    expect(@page.preview).to have_content '(will last around 45 to 60 minutes)'

    expect(@page.preview).to have_content '23 October 1950'
    expect(@page.preview).to have_content 'Some Person'
    expect(@page.preview).to have_content 'email@example.org'
    expect(@page.preview).to have_content '0000000'
    expect(@page.preview).to have_content '1111111'
    expect(@page.preview).to have_content 'lozenge'
    expect(@page.preview).to have_content 'something'
    expect(@page.preview).to have_content 'Opted out'
    expect(@page.preview).to have_content 'Standard'
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
    expect(appointment.date_of_birth.to_s).to eq '1950-10-23'
    expect(appointment.first_name).to eq 'Some'
    expect(appointment.last_name).to eq 'Person'
    expect(appointment.email).to eq 'email@example.org'
    expect(appointment.phone).to eq '0000000'
    expect(appointment.mobile).to eq '1111111'
    expect(appointment.memorable_word).to eq 'lozenge'
    expect(appointment.notes).to eq 'something'
    expect(appointment.opt_out_of_market_research).to eq true
    expect(appointment.start_at).to eq day.change(hour: 9, min: 30).to_s
    expect(appointment.status).to eq 'pending'
    expect(appointment.end_at).to eq day.change(hour: 10, min: 40).to_s
    expect(appointment.type_of_appointment).to eq('standard')
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
    expect(deliveries.first.body.encoded).to include 'We=E2=80=99ve updated your appointment'
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

  def when_they_accept_the_appointment_preview
    @page = Pages::PreviewAppointment.new
    expect(@page).to be_displayed
    @page.confirm_appointment.click
  end

  def when_they_go_back_to_edit_their_appointment
    @page = Pages::PreviewAppointment.new
    expect(@page).to be_displayed
    @page.edit_appointment.click
  end

  def and_they_change_some_details
    @page = Pages::NewAppointment.new

    @page.date_of_birth_day.set '26'
    @page.date_of_birth_month.set '12'
    @page.date_of_birth_year.set '1949'
    @page.first_name.set 'Another'
    @page.last_name.set 'Name'
    @page.email.set 'something@example.org'
    @page.phone.set '99999999'
    @page.mobile.set '8888888'
    @page.memorable_word.set 'orange'
    @page.notes.set 'no notes'
    @page.opt_out_of_market_research.set false
    @page.start_at.set day.change(hour: 9, min: 30).to_s
    @page.end_at.set day.change(hour: 10, min: 40).to_s
    @page.type_of_appointment_50_54.set true

    @page.preview_appointment.click
  end

  def when_they_change_the_appointment_first_name
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
    @page.first_name.set 'Another'
    @page.submit.click
  end

  def then_the_appointment_is_created_with_the_changed_details
    @guider.reload
    expect(Appointment.count).to eq 1
    appointment = Appointment.first

    expect(appointment.agent).to eq current_user
    expect(appointment.guider).to eq @guider
    expect(appointment.date_of_birth.to_s).to eq '1949-12-26'
    expect(appointment.first_name).to eq 'Another'
    expect(appointment.last_name).to eq 'Name'
    expect(appointment.email).to eq 'something@example.org'
    expect(appointment.phone).to eq '99999999'
    expect(appointment.mobile).to eq '8888888'
    expect(appointment.memorable_word).to eq 'orange'
    expect(appointment.notes).to eq 'no notes'
    expect(appointment.opt_out_of_market_research).to eq false
    expect(appointment.start_at).to eq day.change(hour: 9, min: 30).to_s
    expect(appointment.status).to eq 'pending'
    expect(appointment.end_at).to eq day.change(hour: 10, min: 40).to_s
    expect(appointment.type_of_appointment).to eq('50-54')
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

  def then_the_appointments_first_name_is_changed
    @appointment.reload
    expect(@appointment.first_name).to eq('Another')
  end

  def and_all_slots_suddenly_become_unavailable
    BookableSlot.delete_all
  end

  def then_they_are_told_that_the_slot_is_unavailable
    expect(@page).to have_slot_unavailable_message
  end

  def when_they_cancel_the_appointment
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
    @page.status.select('Cancelled By Pension Wise')
    @page.submit.click
  end

  def when_they_cancel_the_appointment_by_order_of_the_customer
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
    @page.status.select('Cancelled By Customer')
    @page.submit.click
  end

  def and_they_change_the_appointment_status
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
    @page.status.select('Incomplete')
    @page.submit.click
  end

  def then_the_customer_gets_a_cancellation_email
    deliveries = ActionMailer::Base.deliveries
    expect(deliveries.count).to eq 1
    expect(deliveries.first.subject).to eq 'Your Pension Wise Appointment'
    expect(deliveries.first.body.encoded).to include 'We=E2=80=99ve cancelled your appointment'
  end

  def then_the_customer_does_not_get_a_cancellation_email
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  def when_they_mark_the_appointment_as_missed
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
    @page.status.select('No Show')
    @page.submit.click
  end

  def then_the_customer_gets_a_missed_appointment_email
    deliveries = ActionMailer::Base.deliveries
    expect(deliveries.count).to eq 1
    expect(deliveries.first.subject).to eq 'Your Pension Wise Appointment'
    expect(deliveries.first.body.encoded).to include(
      'Our records show that your Pension Wise telephone appointment was missed'
    )
  end

  def and_there_is_an_imported_appointment
    @appointment = create(:imported_appointment)
  end

  def when_they_edit_the_appointment
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
  end

  def then_they_see_that_the_appointment_was_imported
    expect(@page).to have_appointment_was_imported_message
  end
end
