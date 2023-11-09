require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Guider views appointments' do
  scenario 'Guider views their own appointments', js: true do
    given_the_user_is_both_guider_and_manager do
      and_there_are_appointments_for_multiple_guiders
      and_the_user_has_a_schedule
      and_the_user_has_a_holiday
      travel_to @appointment.start_at do
        when_they_view_their_calendar
        then_they_see_the_appointment_for_today
        and_they_see_their_schedule_for_today
        and_they_can_see_their_holiday_for_today
        when_they_advance_a_working_day
        then_they_see_the_appointment_for_that_day
        and_they_see_their_schedule_for_tomorrow
        and_they_can_edit_the_appointment
      end
    end
  end

  scenario 'Guider views all appointments', js: true do
    given_the_user_is_a_guider do
      and_there_are_appointments_for_multiple_guiders
      travel_to @appointment.start_at do
        when_they_view_the_company_calendar
        then_they_see_the_appointments_for_today
        when_they_advance_a_working_day
        then_they_see_the_appointments_for_that_day
        and_they_can_edit_an_appointment
      end
    end
  end

  scenario 'Guider does not see deactivated and/or other organisation guiders', js: true do
    given_the_user_is_a_guider do
      and_there_is_a_guider_from_another_organisation
      and_there_is_a_deactivated_guider
      when_they_view_the_company_calendar
      then_they_see_the_guider
      and_they_do_not_see_the_deactivated_guider
      and_they_do_not_see_the_guider_from_another_organisation
    end
  end

  scenario 'Guider views their own appointments and is notified of appointment changes', js: true do
    given_the_requisite_data

    travel_to @appointment.start_at do
      given_a_browser_session_for(@guider) do
        when_they_view_their_calendar
      end

      given_a_browser_session_for(@resource_manager) do
        and_they_assign_the_appointment_to_another_guider
      end

      given_a_browser_session_for(@guider) do
        then_they_are_notified_of_the_change
        and_the_appointment_is_removed_from_their_calendar
      end
    end
  end

  scenario 'Guider views all appointments and is notified of appointment changes', js: true do
    given_the_requisite_data

    travel_to @appointment.start_at do
      given_a_browser_session_for(@guider) do
        when_they_view_the_company_calendar
      end

      given_a_browser_session_for(@resource_manager) do
        and_they_assign_the_appointment_to_another_guider
      end

      given_a_browser_session_for(@guider) do
        then_they_are_notified_of_the_change
        and_the_appointment_is_visibly_assigned_to_the_other_guider
      end
    end
  end

  def given_the_requisite_data
    @guider = create(:guider)
    @appointment = create(:appointment, guider: @guider, start_at: BusinessDays.from_now(10).change(hour: 9))
    @other_guider = create(:guider)
    @resource_manager = create(:resource_manager)
  end

  def and_they_assign_the_appointment_to_another_guider
    @page = Pages::Allocations.new.tap(&:load)
    expect(@page).to be_displayed
    @page.wait_until_appointments_visible

    @page.reassign(@page.appointments.first, guider: @other_guider)
    @page.wait_until_action_panel_visible
    @page.action_panel.save.click
    @page.wait_until_saved_changes_message_visible
  end

  def then_they_are_notified_of_the_change
    @page = Pages::MyAppointments.new

    @page.wait_until_notification_visible

    expect(@page.notification.customer.text).to include(@appointment.name)
    expect(@page.notification.guider.text).to include(@other_guider.name)
  end

  def and_the_appointment_is_removed_from_their_calendar
    expect(@page.calendar.events).to be_empty
  end

  def and_the_appointment_is_visibly_assigned_to_the_other_guider
    expect(@page.calendar.appointments.first[:resourceId]).to eq @other_guider.id
  end

  def and_there_are_appointments_for_multiple_guiders
    start_at = BusinessDays.from_now(10).change(hour: 14)
    # this would appear 'today'
    @appointment = create(:appointment, guider: current_user, start_at:)
    @other_appointment = create(:appointment, guider: create(:guider), start_at:)
    # this would appear 'tomorrow'
    @appointment_tomorrow = create(
      :appointment,
      guider: current_user,
      start_at: BusinessDays.from_now(11).at_midday
    )
  end

  def and_the_user_has_a_schedule
    today    = BusinessDays.from_now(10).beginning_of_day
    tomorrow = BusinessDays.from_now(11).beginning_of_day
    # this would appear 'today'
    @bookable_slots = [
      current_user.bookable_slots.create(
        start_at: today.change(hour: 14),
        end_at: today.change(hour: 15)
      ),
      # this would appear 'tomorrow'
      current_user.bookable_slots.create(
        start_at: tomorrow.change(hour: 15),
        end_at: tomorrow.change(hour: 16)
      )
    ]
  end

  def and_the_user_has_a_holiday
    today = BusinessDays.from_now(10).beginning_of_day
    @holiday = create(
      :holiday,
      user: current_user,
      start_at: today.change(hour: 17),
      end_at: today.change(hour: 18)
    )
  end

  def when_they_view_their_calendar
    @page = Pages::MyAppointments.new.tap(&:load)
  end

  def when_they_view_the_company_calendar
    @page = Pages::CompanyCalendar.new.tap(&:load)
  end

  def then_they_see_the_appointment_for_today
    @page.wait_until_appointments_visible
    expect(@page).to have_appointments(count: 1)

    @page.appointments.first.tap do |appointment|
      expect(appointment.title.text).to include(@appointment.first_name)
      expect(appointment.title.text).to include(@appointment.last_name)
      expect(appointment.title.text).to include(@appointment.memorable_word)
      expect(appointment.title.text).to include(@appointment.phone)
    end
  end

  def and_they_see_their_schedule_for_today
    event = @page.calendar.slots.min_by { |slot| slot[:start] }
    expect(Time.zone.parse(event[:start])).to eq @bookable_slots.first.start_at
    expect(Time.zone.parse(event[:end])).to eq @bookable_slots.first.end_at
  end

  def and_they_can_see_their_holiday_for_today
    event = @page.calendar.holidays.max_by { |slot| slot[:start] }
    expect(Time.zone.parse(event[:start])).to eq @holiday.start_at
    expect(Time.zone.parse(event[:end])).to eq @holiday.end_at
  end

  def then_they_see_the_appointments_for_today
    @page.wait_until_appointments_visible

    expect(@page).to have_appointments(count: 2)

    actual = @page.appointments.map { |a| a['id'].to_i }.sort
    expected = [
      @appointment.id,
      @other_appointment.id
    ].sort

    expect(actual).to eq expected
  end

  def when_they_advance_a_working_day
    next_working_day = BusinessDays.from_now(1).to_date

    @page.next_week_day.click until Date.parse(@page.date.text) == next_working_day
  end

  def then_they_see_the_appointment_for_that_day
    @page.wait_until_appointments_visible
    expect(@page).to have_appointments(count: 1)

    expect(@page.appointments.first.text).to include(@appointment_tomorrow.first_name)
  end

  def and_they_see_their_schedule_for_tomorrow
    event = @page.calendar.slots.max_by { |slot| slot[:start] }
    expect(Time.zone.parse(event[:start])).to eq @bookable_slots.second.start_at
    expect(Time.zone.parse(event[:end])).to eq @bookable_slots.second.end_at
  end

  def then_they_see_the_appointments_for_that_day
    @page.wait_until_appointments_visible
    expect(@page).to have_appointments(count: 1)

    actual = @page.appointments.first['id']

    expect(actual).to eq(@appointment_tomorrow.id.to_s)
  end

  def and_they_can_edit_the_appointment
    expect(@page.appointments.first.root_element['href']).to end_with(edit_appointment_path(@appointment_tomorrow))
  end

  def and_they_can_edit_an_appointment
    expect(@page.appointments.first['href']).to end_with(edit_appointment_path(@appointment_tomorrow))
  end

  def and_there_is_a_guider_from_another_organisation
    @guider    = create(:guider, :tpas)
    @tp_guider = create(:guider, :tp)
  end

  def and_they_do_not_see_the_guider_from_another_organisation
    expect(@page.calendar.guiders).to_not include(@tp_guider.name)
  end

  def and_there_is_a_deactivated_guider
    @deactivated_guider = create(:deactivated_guider)
  end

  def then_they_see_the_guider
    expect(@page.calendar.guiders).to include @guider.name
  end

  def and_they_do_not_see_the_deactivated_guider
    expect(@page.calendar.guiders).to_not include @deactivated_guider.name
  end
end
# rubocop:enable Metrics/BlockLength
