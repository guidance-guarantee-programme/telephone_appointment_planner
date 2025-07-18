require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Agent manages appointments' do
  before do
    [
      PusherAppointmentChangedJob,
      AppointmentCreatedNotificationsJob,
      CustomerUpdateJob,
      PushCasebookAppointmentJob,
      AdjustmentNotificationsJob,
      SmsAppointmentConfirmationJob,
      PrintedConfirmationJob
    ].each do |expected_job|
      allow(expected_job).to receive(:perform_later)
    end
  end

  let(:day) { BusinessDays.from_now(5) }

  scenario 'Non Cardiff and Vale cannot place Welsh bookings' do
    given_the_user_is_a_resource_manager(organisation: :waltham_forest) do
      when_they_try_to_book_an_appointment
      then_they_do_not_see_the_welsh_language_option
    end
  end

  scenario 'Pension Ops/TPAS can place Welsh language bookings' do
    given_the_user_is_a_resource_manager(organisation: :tpas) do
      and_there_is_a_guider_with_available_slots(organisation: :tpas)
      when_they_attempt_to_book_a_welsh_appointment
      then_they_see_a_preview_of_the_appointment(welsh: true)
      when_they_accept_the_appointment_preview
      then_the_appointment_is_welsh
    end
  end

  scenario 'Cardiff and Vale can place Welsh bookings' do
    given_the_user_is_a_resource_manager(organisation: :cardiff_and_vale) do
      and_there_is_a_guider_with_available_slots(organisation: :cardiff_and_vale)
      when_they_attempt_to_book_a_welsh_appointment
      then_they_see_a_preview_of_the_appointment(welsh: true)
      when_they_accept_the_appointment_preview
      then_the_appointment_is_welsh
    end
  end

  scenario 'Resending a printed confirmation letter', js: true do
    given_the_user_is_a_resource_manager(organisation: :tpas) do
      and_an_appointment_with_an_address_exists
      when_they_edit_the_appointment
      and_they_resend_the_printed_confirmation
      then_the_printed_confirmation_is_sent
    end
  end

  scenario 'TP agent booking a stronger nudge appointment' do
    given_the_user_is_an_agent(organisation: :tp) do
      and_there_is_a_guider_with_available_slots
      when_they_attempt_to_book_an_appointment
      and_they_complete_the_stronger_nudge_booking
      then_they_see_a_preview_of_the_appointment(stronger_nudge: true)
      when_they_accept_the_appointment_preview
      then_the_appointment_is_stronger_nudge
    end
  end

  scenario 'TPAS agent sees the stronger nudge checkbox' do
    given_the_user_is_a_resource_manager(organisation: :tpas) do
      when_they_attempt_to_book_an_appointment
      then_they_see_the_stronger_nudge_checkbox
    end
  end

  scenario 'Attempting to update an appointment with invalid fields' do
    given_the_user_is_a_resource_manager(organisation: :tpas) do
      and_an_appointment_exists
      when_they_edit_the_appointment
      and_set_invalid_fields
      then_they_see_an_error_banner
    end
  end

  scenario 'TPAS user viewing allocations calendar' do
    given_the_user_is_a_resource_manager(organisation: :tpas) do
      travel_to '2021-12-15 13:00' do
        when_they_view_the_allocations_calendar
        then_they_see_the_longer_grace_period
      end
    end
  end

  scenario 'TPAS user booking a Pension Wise appointment', js: true do
    travel_to '2021-04-05 10:00' do
      given_the_user_is_a_resource_manager(organisation: :tpas) do
        and_slots_exist_for_general_availability
        and_slots_exist_for_due_diligence_availability
        when_they_attempt_to_book_an_appointment
        and_choose_internal_availability
        then_they_see_only_general_availability
      end
    end
  end

  def when_they_try_to_book_an_appointment
    @page = Pages::NewAppointment.new.tap(&:load)
    expect(@page).to be_displayed
  end

  def then_they_do_not_see_the_welsh_language_option
    expect(@page).not_to have_welsh
  end

  def and_an_appointment_with_an_address_exists
    @appointment = create(:appointment, :with_address)
  end

  def and_they_resend_the_printed_confirmation
    accept_confirm do
      @page.resend_print_confirmation.click
    end
  end

  def then_the_printed_confirmation_is_sent
    expect(@page.flash_of_success).to have_text('letter was resent')
  end

  def then_they_see_the_stronger_nudge_checkbox
    expect(@page.stronger_nudged).to be_visible
  end

  def when_they_attempt_to_book_a_welsh_appointment
    @page = Pages::NewAppointment.new.tap(&:load)
    expect(@page).to be_displayed

    fill_in_appointment_details(welsh: true)
  end

  def then_the_appointment_is_welsh
    then_that_appointment_is_created(welsh: true)
  end

  def and_they_complete_the_stronger_nudge_booking
    fill_in_appointment_details(stronger_nudge: true)
  end

  def then_the_appointment_is_stronger_nudge
    then_that_appointment_is_created(stronger_nudge: true)
  end

  def when_they_view_the_allocations_calendar
    @page = Pages::Allocations.new.tap(&:load)
  end

  def then_they_see_the_longer_grace_period
    expect(@page.due_diligence_grace_period).to have_text('23 December 2021')
  end

  def and_slots_exist_for_due_diligence_availability
    create(:bookable_slot, :due_diligence, start_at: Time.zone.parse('2021-04-08 14:30'))
  end

  def then_they_see_only_general_availability
    @page.wait_until_calendar_events_visible

    expect(@page).to have_calendar_events(count: 1)
    expect(@page.calendar_events.first).to have_text('April 8th 2021 12:30')
  end

  def and_choose_internal_availability
    @page.internal_availability.check
  end

  scenario 'Outsider trying to book Lloyds' do
    given_the_user_is_a_resource_manager do
      when_they_want_to_book_an_appointment
      then_they_cannot_specify_lloyds_signposted
    end
  end

  scenario 'Lancs West guider modifying BSL' do
    given_the_user_is_an_agent(organisation: :lancashire_west) do
      when_they_want_to_book_an_appointment
      then_they_can_specify_bsl_video
    end
  end

  scenario 'TP agent cannot modify BSL' do
    given_the_user_is_an_agent(organisation: :tp) do
      when_they_want_to_book_an_appointment
      then_bsl_video_is_disabled
    end
  end

  scenario 'Third party consent', js: true do
    given_the_user_is_an_agent do
      when_they_want_to_book_an_appointment
      and_they_declare_a_third_party_booking
      then_they_see_the_correct_consent_fields
    end
  end

  scenario 'Appointment types are inferred from date of birth', js: true do
    given_the_user_is_an_agent do
      when_they_want_to_book_an_appointment
      and_they_enter_a_standard_date_of_birth
      then_they_do_not_see_the_eligibility_reason
      then_the_standard_appointment_type_is_selected
      when_they_enter_a_50_to_54_date_of_birth
      then_the_50_to_54_appointment_type_is_selected
      when_they_enter_a_less_than_50_date_of_birth
      then_they_see_the_eligibility_reason
    end
  end

  scenario 'Agent creates appointments' do
    given_the_user_is_an_agent do
      and_there_is_a_guider_with_available_slots
      and_there_is_duplicate_appointment
      when_they_want_to_book_an_appointment
      then_they_do_not_see_the_smarter_signposting_option
      and_they_fill_in_their_appointment_details
      then_they_see_a_preview_of_the_appointment(duplicates: true)
      when_they_accept_the_appointment_preview
      then_that_appointment_is_created
      and_the_customer_gets_an_email_confirmation
      and_a_printed_confirmation_job_is_enqueued
      and_the_system_attempts_to_push_to_casebook
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

  scenario 'Agent marks an appointment as no-show', js: true do
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

  scenario 'Agent sets a secondary status', js: true do
    given_the_user_is_an_agent do
      and_there_is_an_appointment
      when_they_edit_the_appointment
      and_they_select_a_secondary_status
      then_the_secondary_status_is_marked
    end
  end

  def when_they_enter_a_less_than_50_date_of_birth
    @page.date_of_birth_day.set '01'
    @page.date_of_birth_month.set '01'
    @page.date_of_birth_year.set '1980'
  end

  def then_they_see_the_eligibility_reason
    @page.wait_until_eligibility_reason_visible
    expect(@page).to have_eligibility_reason
  end

  def then_they_do_not_see_the_eligibility_reason
    expect(@page).to have_no_eligibility_reason
  end

  def when_they_submit_with_errors
    @page.date_of_birth_day.set '23'
    @page.date_of_birth_month.set '10'
    @page.date_of_birth_year.set '1930'

    @page.preview_appointment.click
  end

  def and_slots_exist_for_lloyds
    create(:bookable_slot, :north_tyneside, start_at: Time.zone.parse('2021-04-07 12:30'))
  end

  def and_slots_exist_for_general_availability
    # TPAS slot
    create(:bookable_slot, start_at: Time.zone.parse('2021-04-08 12:30'))
  end

  def when_they_attempt_to_book_an_appointment
    @page = Pages::NewAppointment.new.tap(&:load)
    expect(@page).to be_displayed
  end

  def then_they_see_all_availability
    @page.wait_until_calendar_events_visible

    expect(@page).to have_calendar_events(count: 2)
  end

  def when_they_choose_lloyds
    @page.lloyds_signposted.set(true)
  end

  def then_they_see_lloyds_availability
    @page.wait_until_calendar_events_visible

    expect(@page).to have_calendar_events(count: 1)
  end

  def then_they_cannot_specify_lloyds_signposted
    expect(@page).to have_no_lloyds_signposted
  end

  def and_they_select_a_secondary_status
    @page.status.select('Pending')
    expect(@page).to have_no_secondary_status_options

    @page.status.select('Cancelled By Customer')
    @page.wait_until_secondary_status_options_visible
    @page.secondary_status.select('Cancelled prior to appointment')
    @page.wait_until_cancelled_via_phone_visible
    @page.cancelled_via_phone.set(true)
    @page.submit.click
  end

  def then_the_secondary_status_is_marked
    expect(@page).to have_flash_of_success
  end

  def then_bsl_video_is_disabled
    expect(@page.bsl_video).to be_disabled
  end

  def then_they_can_specify_bsl_video
    @page.bsl_video.set(true)
  end

  def then_they_do_not_see_the_smarter_signposting_option
    expect(@page).to have_no_smarter_signposted
  end

  def and_they_declare_a_third_party_booking
    expect(@page).to have_no_data_subject_name

    @page.third_party_booked.set(true)
  end

  def then_they_see_the_correct_consent_fields
    expect(@page).to have_data_subject_name
    expect(@page).to have_data_subject_date_of_birth_day
    expect(@page).to have_data_subject_date_of_birth_month
    expect(@page).to have_data_subject_date_of_birth_year
  end

  def and_the_system_attempts_to_push_to_casebook
    expect(PushCasebookAppointmentJob).to have_received(:perform_later)
  end

  def and_they_enter_a_standard_date_of_birth
    @page.date_of_birth_day.set '23'
    @page.date_of_birth_month.set '10'
    @page.date_of_birth_year.set '1930'
  end

  def then_the_standard_appointment_type_is_selected
    expect(@page.type_of_appointment_standard).to be_checked
  end

  def when_they_enter_a_50_to_54_date_of_birth
    @page.date_of_birth_year.set '1970'
  end

  def then_the_50_to_54_appointment_type_is_selected
    expect(@page.type_of_appointment_50_54).to be_checked
  end

  def and_there_is_a_guider_with_available_slots(organisation: :tpas)
    @guider = create(:guider, organisation)
    slots = [
      build(:nine_thirty_slot, day_of_week: day.wday),
      build(:four_fifteen_slot, day_of_week: day.wday)
    ]
    @schedule = @guider.schedules.build(
      start_at: day.beginning_of_day,
      slots:
    )
    @schedule.save!
    BookableSlot.generate_for_booking_window
  end

  def and_there_is_duplicate_appointment
    create(:appointment, first_name: 'Some', last_name: 'Person', date_of_birth: '1950-10-23')
  end

  def fill_in_appointment_details(options = {}) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    @page.date_of_birth_day.set '23'
    @page.date_of_birth_month.set '10'
    @page.date_of_birth_year.set '1950'
    @page.first_name.set 'Some'
    @page.last_name.set 'Person'
    @page.email.set options[:email] || 'email@example.org'
    @page.phone.set '0208 252 4729'
    @page.mobile.set '07715 930 459'
    @page.memorable_word.set 'lozenge'
    @page.accessibility_requirements.set true
    @page.adjustments.set 'The given adjustments'
    @page.notes.set 'something'
    @page.gdpr_consent_yes.set true
    @page.internal_availability.set true if @page.has_internal_availability?
    @page.start_at.set day.change(hour: 9, min: 30).to_s
    @page.end_at.set day.change(hour: 10, min: 40).to_s
    @page.type_of_appointment_standard.set true
    @page.where_you_heard.select 'Other'
    @page.welsh.set(options[:welsh]) if options[:welsh]
    @page.address_line_one.set(options[:address_line_one]) if options[:address_line_one]
    @page.town.set(options[:town]) if options[:town]
    @page.postcode.set(options[:postcode]) if options[:postcode]
    @page.stronger_nudged.set(options[:stronger_nudge]) if options[:stronger_nudge]
    @page.attended_digital_yes.set(true) if options[:attended_digital]

    expect(@page).to have_no_bsl_video if options[:bsl_video]

    @page.preview_appointment.click
  end

  def and_they_fill_in_their_appointment_details(options = {})
    fill_in_appointment_details(options)
  end

  def then_they_see_a_preview_of_the_appointment(options = {})
    @page = Pages::PreviewAppointment.new
    expect(@page).to be_displayed

    expect(@page).to have_duplicates if options[:duplicates]

    expect(@page.preview).to have_content "#{day.to_date.to_formatted_s(:govuk_date)} 9:30am"
    expect(@page.preview).to have_content '(will last around 60 minutes)'

    expect(@page.preview).to have_content '23 October 1950'
    expect(@page.preview).to have_content 'Some Person'
    expect(@page.preview).to have_content 'email@example.org'
    expect(@page.preview).to have_content '0208 252 4729'
    expect(@page.preview).to have_content '07715 930 459'
    expect(@page.preview).to have_content 'lozenge'
    expect(@page.preview).to have_content 'something'
    expect(@page.preview).to have_content 'Customer research consent Yes'
    expect(@page.preview).to have_content 'I require help or an adjustment to help me access my appointment Yes'
    expect(@page.preview).to have_content 'The given adjustments'
    expect(@page.preview).to have_content 'Customer research consent Yes'
    expect(@page.preview).to have_content 'Standard'
    expect(@page.preview).to have_content 'Stronger Nudge appointment? Yes' if options[:stronger_nudge]
    expect(@page.preview).to have_content 'Welsh language appointment? Yes' if options[:welsh]
    expect(@page.preview).to have_content 'online Pension Wise appointment? Yes' if options[:attended_digital]
  end

  def and_they_fill_in_their_appointment_details_without_an_email
    fill_in_appointment_details(
      email: '',
      address_line_one: '10 Some Street',
      town: 'Romford',
      postcode: 'RM1 1AL'
    )
  end

  def then_that_appointment_is_created(options = {})
    @guider.reload
    appointment = Appointment.last

    expect(appointment.agent).to eq current_user
    expect(appointment.guider).to eq @guider
    expect(appointment.date_of_birth.to_s).to eq '1950-10-23'
    expect(appointment.first_name).to eq 'Some'
    expect(appointment.last_name).to eq 'Person'
    expect(appointment.email).to eq 'email@example.org'
    expect(appointment.phone).to eq '0208 252 4729'
    expect(appointment.mobile).to eq '07715 930 459'
    expect(appointment.memorable_word).to eq 'lozenge'
    expect(appointment.notes).to eq 'something'
    expect(appointment.adjustments).to eq 'The given adjustments'
    expect(appointment.gdpr_consent).to eq 'yes'
    expect(appointment.start_at).to eq day.change(hour: 9, min: 30).to_s
    expect(appointment.status).to eq 'pending'
    expect(appointment.end_at).to eq day.change(hour: 10, min: 40).to_s
    expect(appointment.type_of_appointment).to eq('standard')
    expect(appointment.where_you_heard).to eq(17)
    expect(appointment).to be_accessibility_requirements
    expect(appointment).to_not be_bsl_video
    expect(appointment).to be_nudged if options[:stronger_nudge]
    expect(appointment).to be_welsh if options[:welsh]
    expect(appointment).to be_attended_digital if options[:attended_digital]
  end

  def and_the_customer_gets_an_email_confirmation
    expect(CustomerUpdateJob).to have_received(:perform_later)
  end

  def and_a_printed_confirmation_job_is_enqueued
    expect(PrintedConfirmationJob).to have_received(:perform_later)
  end

  def and_the_customer_gets_an_updated_email_confirmation
    expect(CustomerUpdateJob).to have_received(:perform_later)
  end

  def then_the_customer_does_not_get_an_email_confirmation
    expect(CustomerUpdateJob).to have_received(:perform_later).once
  end

  def then_the_customer_does_not_get_an_updated_email_confirmation
    expect(CustomerUpdateJob).to have_received(:perform_later).once
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
    @page.phone.set '02082524729'
    @page.mobile.set '07715930459'
    @page.memorable_word.set 'orange'
    @page.notes.set 'no notes'
    @page.gdpr_consent_yes.set true
    @page.start_at.set day.change(hour: 9, min: 30).to_s
    @page.end_at.set day.change(hour: 10, min: 40).to_s
    @page.type_of_appointment_50_54.set true
    @page.accessibility_requirements.set false

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
    expect(appointment.phone).to eq '02082524729'
    expect(appointment.mobile).to eq '07715930459'
    expect(appointment.memorable_word).to eq 'orange'
    expect(appointment.notes).to eq 'no notes'
    expect(appointment.gdpr_consent).to eq 'yes'
    expect(appointment.start_at).to eq day.change(hour: 9, min: 30).to_s
    expect(appointment.status).to eq 'pending'
    expect(appointment.end_at).to eq day.change(hour: 10, min: 40).to_s
    expect(appointment.type_of_appointment).to eq('50-54')
    expect(appointment).not_to be_accessibility_requirements
  end

  def and_there_is_an_appointment
    @appointment = create(:appointment)
  end

  def and_there_is_an_appointment_without_an_email
    @appointment = create(:appointment, :with_address, email: nil)
  end

  def and_they_want_to_reschedule_the_appointment
    @page = Pages::RescheduleAppointment.new
    @page.load(id: @appointment.id)
  end

  def when_they_reschedule_the_appointment
    expect(@page).to have_no_availability_calendar_off
    @page.start_at.set day.change(hour: 16, min: 15).to_s
    @page.end_at.set day.change(hour: 17, min: 15).to_s
    @page.reschedule.click
  end

  def then_the_appointment_is_rescheduled
    appointment = Appointment.first
    expect(appointment.start_at).to eq day.change(hour: 16, min: 15).to_s
    expect(appointment.end_at).to eq day.change(hour: 17, min: 15).to_s

    expect(appointment).to be_rescheduled_at
    expect(appointment).not_to be_batch_processed_at
    expect(appointment.rescheduling_reason).to eq('client_rescheduled')
    expect(appointment.rescheduling_route).to eq('phone')
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
    @page.status.select('Cancelled By Customer Sms')
    @page.submit.click
  end

  def when_they_cancel_the_appointment_by_order_of_the_customer
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
    @page.status.select('Cancelled By Customer Sms')
    @page.submit.click
  end

  def and_they_change_the_appointment_status
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
    @page.status.select('Incomplete')
    @page.submit.click
  end

  def then_the_customer_gets_a_cancellation_email
    expect(CustomerUpdateJob).to have_received(:perform_later)
  end

  def then_the_customer_does_not_get_a_cancellation_email
    expect(CustomerUpdateJob).to_not have_received(:perform_later)
  end

  def when_they_mark_the_appointment_as_missed
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)
    @page.status.select('No Show')
    @page.wait_until_secondary_status_options_visible
    @page.secondary_status.select('UK number invalid')
    @page.submit.click
    expect(@page).to have_flash_of_success
  end

  def then_the_customer_gets_a_missed_appointment_email
    expect(CustomerUpdateJob).to have_received(:perform_later)
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

  def and_an_appointment_exists
    @appointment = create(:appointment)
  end

  def and_set_invalid_fields
    @page.first_name.set ''
    @page.submit.click
  end

  def then_they_see_an_error_banner
    expect(@page).to have_flash_of_danger
  end
end
# rubocop:enable Metrics/BlockLength
