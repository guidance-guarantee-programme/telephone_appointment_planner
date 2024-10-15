require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Resource manager modifies appointments' do
  scenario 'Avoid navigating away with unsaved modifications', js: true do
    given_the_user_is_a_resource_manager do
      when_there_are_appointments_for_multiple_guiders
      travel_to @appointment.start_at do
        when_they_view_the_appointments
        then_they_see_appointments_for_multiple_guiders
        when_they_change_the_guider
        and_click_a_link_while_dismissing_the_warning
        then_they_do_not_navigate_away
      end
    end
  end

  scenario 'Do not track changes to secondary statuses', js: true do
    given_the_user_is_a_resource_manager do
      and_there_is_an_appointment
      when_they_edit_the_appointment_secondary_status
      then_they_can_navigate_away_without_warning
    end
  end

  scenario 'Reassigning the chosen guider alerts both guiders', js: true do
    skip 'This is flakey and needs to be addressed'

    # create the guiders and appointments up front
    when_there_are_appointments_for_multiple_guiders

    # start Ben and Jan's sessions to subscribe on the pusher channel
    given_a_browser_session_for(@ben, @jan) do
      when_they_view_their_appointments
      wait_for_ajax_to_complete
    end

    # start resource manager's session and reassign the appointment
    given_the_user_is_a_resource_manager do
      travel_to @appointment.start_at do
        when_they_view_the_appointments
        then_they_see_appointments_for_multiple_guiders
        when_they_change_the_guider
        and_commit_their_modifications
        then_the_guider_is_modified
        and_no_customer_notifications_are_sent
      end
    end

    # go back to Ben and Jan's sessions and check for the notifications
    given_a_browser_session_for(@ben, @jan) do
      then_they_are_notified_of_the_change
      wait_for_ajax_to_complete
    end

    wait_for_ajax_to_complete
  end

  scenario 'Rescheduling an appointment notifies the guider and customer', js: true do
    # create the guiders and appointments up front
    when_there_are_appointments_for_multiple_guiders

    # start Ben's session to subscribe on the pusher channel
    given_a_browser_session_for(@ben) do
      when_they_view_their_appointments
    end

    # reschedule the appointment
    given_the_user_is_a_resource_manager do
      travel_to @appointment.start_at do
        when_they_view_the_appointments
        then_they_see_appointments_for_multiple_guiders
        when_they_reschedule_an_appointment
        and_commit_their_modifications
        then_the_appointment_is_modified
        and_the_customer_is_notified_of_the_appointment_change
      end
    end

    # go back to Ben and check for notifications
    given_a_browser_session_for(@ben) do
      then_they_are_notified_of_the_rescheduling
    end
  end

  scenario 'Viewing holidays for one guider', js: true do
    given_the_user_is_a_resource_manager do
      and_there_is_a_holiday_for_one_guider
      travel_to @holiday.start_at do
        when_they_view_the_appointments
        then_they_see_the_holiday_for_one_guider
      end
    end
  end

  scenario 'Viewing holidays for all guiders', js: true do
    given_the_user_is_a_resource_manager do
      and_there_is_a_holiday_for_all_guiders
      travel_to @holiday.start_at do
        when_they_view_the_appointments
        then_they_see_the_holiday_for_all_guiders
      end
    end
  end

  scenario 'Creating a holiday for one guider', js: true do
    given_the_user_is_a_resource_manager do
      travel_to BusinessDays.from_now(1) do
        and_there_is_a_guider
        when_they_view_the_appointments
        and_they_create_a_holiday_for_the_guider
        then_there_is_a_holiday_for_that_guider
      end
    end
  end

  scenario 'Viewing bookable slots', js: true do
    given_the_user_is_a_resource_manager do
      and_there_is_a_bookable_slot_for_a_guider
      travel_to @bookable_slot.start_at do
        when_they_view_the_appointments
        then_they_can_see_the_bookable_slot
      end
    end
  end

  def and_there_is_an_appointment
    @appointment = create(:appointment, status: :cancelled_by_customer, secondary_status: '15')
  end

  def when_they_edit_the_appointment_secondary_status
    @page = Pages::EditAppointment.new
    @page.load(id: @appointment.id)

    @page.secondary_status.select('Customer forgot')
  end

  def then_they_can_navigate_away_without_warning
    @page.click_on('Appointment search')

    expect(@page).to be_displayed
  end

  def and_there_is_a_holiday_for_one_guider
    start_at = BusinessDays.from_now(2).change(hour: 9)
    @holiday = create(
      :holiday,
      user: create(:guider),
      start_at:,
      end_at: start_at + 1.hour
    )
  end

  def and_there_is_a_holiday_for_all_guiders
    start_at = BusinessDays.from_now(3).change(hour: 9)
    @holiday = create(
      :bank_holiday,
      start_at:,
      end_at: start_at + 1.hour
    )
  end

  def and_there_is_a_bookable_slot_for_a_guider
    guider = create(:guider)
    today = BusinessDays.from_now(10)

    @bookable_slot = guider.bookable_slots.create(
      start_at: today.change(hour: 11, min: 0),
      end_at: today.change(hour: 12, min: 10)
    )
  end

  def and_there_is_a_guider
    @guider = create(:guider)
  end

  def then_they_can_see_the_bookable_slot
    event = @page.calendar.slots.first
    expect(Time.zone.parse(event[:start])).to eq @bookable_slot.start_at
    expect(Time.zone.parse(event[:end])).to eq @bookable_slot.end_at
  end

  def and_no_customer_notifications_are_sent
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  def when_they_view_their_appointments
    @page = Pages::MyAppointments.new.tap(&:load)
  end

  def then_they_are_notified_of_the_change
    @page = Pages::MyAppointments.new
    @page.wait_until_notification_visible

    expect(@page.notification.customer.text).to include(@appointment.name)
    expect(@page.notification.guider.text).to include(@jan.name)
  end

  def then_they_are_notified_of_the_rescheduling
    @page = Pages::MyAppointments.new
    @page.wait_until_notification_visible

    expect(@page.notification.customer.text).to include(@appointment.name)
    expect(@page.notification.guider.text).to include(@ben.name)
    expect(@page.notification.start.text).to include(@appointment.start_at.strftime('%d %B %Y %H:%M'))
  end

  def when_they_change_the_guider
    @page.reassign(@page.appointments.first, guider: @jan)

    # this is being triggered for test purposes only
    @page.wait_until_rescheduling_reason_modal_visible
    @page.rescheduling_reason_modal.pension_wise.set(true)
    @page.rescheduling_reason_modal.save.click
  end

  def then_the_guider_is_modified
    expect(@appointment.reload.guider_id).to eq(@jan.id)
  end

  def when_there_are_appointments_for_multiple_guiders
    @ben = create(:guider, name: 'Ben Lovell')
    @jan = create(:guider, name: 'Jan Schwifty')

    @appointment = create(:appointment, guider: @ben, start_at: Time.zone.parse('2021-03-11 09:00'))
    @other_appointment = create(:appointment, guider: @jan, start_at: Time.zone.parse('2021-03-11 09:30'))
  end

  def then_they_see_the_holiday_for_one_guider
    @page.calendar.wait_until_background_events_visible
    holiday = @page.calendar.find_holiday_by_id(@holiday.id)
    expect(holiday[:title]).to eq @holiday.title
    expect(holiday[:resourceId]).to eq @holiday.user.id
  end

  def then_they_see_the_holiday_for_all_guiders
    holiday = @page.calendar.find_holiday_by_id(@holiday.id)
    expect(holiday[:title]).to eq @holiday.title
    expect(holiday[:resourceId]).to be_nil
  end

  def when_they_view_the_appointments
    @page = Pages::Allocations.new.tap(&:load)
    expect(@page).to be_displayed
  end

  def then_they_see_appointments_for_multiple_guiders
    @page.wait_until_guiders_visible
    expect(@page).to have_guiders(count: 2)
    expect(@page.guiders.first).to have_text('Ben Lovell')

    @page.wait_until_appointments_visible
    expect(@page).to have_appointments(count: 2)
  end

  def when_they_reschedule_an_appointment
    @page.reschedule(@page.appointments.first, hours: 13, minutes: 30)

    @page.wait_until_rescheduling_reason_modal_visible
    @page.rescheduling_reason_modal.pension_wise.set(true)
    expect(@page.rescheduling_reason_modal).to have_no_via_phone
    @page.rescheduling_reason_modal.client.set(true)
    @page.rescheduling_reason_modal.wait_until_via_phone_visible
    @page.rescheduling_reason_modal.via_phone.set(true)
    @page.rescheduling_reason_modal.save.click
  end

  def and_commit_their_modifications
    @page.wait_until_action_panel_visible
    @page.action_panel.save.click
    @page.wait_until_saved_changes_message_visible
  end

  def then_the_appointment_is_modified
    @appointment.reload

    expect(@appointment.start_at.hour).to eq(13)
    expect(@appointment.start_at.min).to eq(30)

    expect(@appointment.end_at.hour).to eq(14)
    expect(@appointment.end_at.min).to eq(30)

    expect(@appointment.rescheduling_reason).to eq('client_rescheduled')
    expect(@appointment.rescheduling_route).to eq('phone')
  end

  def and_the_customer_is_notified_of_the_appointment_change
    deliveries = ActionMailer::Base.deliveries
    expect(deliveries.count).to eq 1
    expect(deliveries.first.to).to eq [@appointment.email]
    expect(deliveries.first.subject).to eq 'Pension Wise Appointment'
    expect(deliveries.first.body.encoded).to include 'We=E2=80=99ve updated your appointment'
  end

  def and_click_a_link_while_dismissing_the_warning
    @page.find('.navbar-brand').click
  end

  def then_they_do_not_navigate_away
    expect(@page.url).to eq(page.current_path)

    # force 'reset' for poltergeist after dismissal of a JS prompt
    visit 'about:blank'
  end

  def and_they_create_a_holiday_for_the_guider
    title = 'Holiday Title'
    stub_prompt_to_return(title)
    @page.calendar.select_holiday_range(@guider.name)

    @page.wait_until_saved_changes_message_visible
  end

  def then_there_is_a_holiday_for_that_guider
    @page.calendar.wait_until_background_events_visible

    date = Time.zone.now.strftime('%Y-%m-%d')
    holiday = @page.calendar.holidays.first
    expect(holiday[:resourceId]).to eq @guider.id
    expect(holiday[:title]).to eq 'Holiday Title'
    expect(holiday[:start]).to eq "#{date}T09:00:00Z"
    expect(holiday[:end]).to eq "#{date}T09:10:00Z"

    expect(Holiday.count).to eq 1
  end

  def wait_for_ajax_to_complete
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until page.evaluate_script('jQuery.active').zero?
    end
  end
end
# rubocop:enable Metrics/BlockLength
