# rubocop:disable Metrics/AbcSize
require 'rails_helper'

RSpec.feature 'Resource manager modifies appointments' do
  scenario 'Rescheduling an appointment', js: true do
    perform_enqueued_jobs do
      given_the_user_is_a_resource_manager do
        and_there_are_appointments_for_multiple_guiders
        travel_to @appointment.start_at do
          when_they_view_the_appointments
          then_they_see_appointments_for_multiple_guiders
          when_they_reschedule_an_appointment
          and_commit_their_modifications
          then_the_appointment_is_modified
          and_the_customer_is_notified_of_the_appointment_change
        end
      end
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

  def and_there_is_a_holiday_for_one_guider
    start_at = BusinessDays.from_now(2).change(hour: 9)
    @holiday = create(
      :holiday,
      user: create(:guider),
      start_at: start_at,
      end_at: start_at + 1.hour
    )
  end

  def and_there_is_a_holiday_for_all_guiders
    start_at = BusinessDays.from_now(3).change(hour: 9)
    @holiday = create(
      :bank_holiday,
      start_at: start_at,
      end_at: start_at + 1.hour
    )
  end

  def and_there_are_appointments_for_multiple_guiders
    @ben = create(:guider, name: 'Ben Lovell')
    @jan = create(:guider, name: 'Jan Schwifty')

    @appointment = create(:appointment, guider: @ben)
    @other_appointment = create(:appointment, guider: @jan)
  end

  def then_they_see_the_holiday_for_one_guider
    holiday = @page.find_holiday(@holiday)
    expect(holiday[:title]).to eq @holiday.title
    expect(holiday[:resourceId]).to eq @holiday.user.id
  end

  def then_they_see_the_holiday_for_all_guiders
    holiday = @page.find_holiday(@holiday)
    expect(holiday[:title]).to eq @holiday.title
    expect(holiday[:resourceId]).to be_nil
  end

  def when_they_view_the_appointments
    @page = Pages::ResourceCalendar.new.tap(&:load)
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
    @page.reschedule(@page.appointments.first, hours: 8, minutes: 30)
  end

  def and_commit_their_modifications
    @page.wait_until_action_panel_visible
    @page.action_panel.save.click
  end

  def then_the_appointment_is_modified
    @appointment.reload

    expect(@appointment.start_at.hour).to eq(8)
    expect(@appointment.start_at.min).to eq(30)

    expect(@appointment.end_at.hour).to eq(9)
    expect(@appointment.end_at.min).to eq(30)
  end

  def and_the_customer_is_notified_of_the_appointment_change
    deliveries = ActionMailer::Base.deliveries
    expect(deliveries.count).to eq 1
    expect(deliveries.first.to).to eq [@appointment.email]
    expect(deliveries.first.subject).to eq 'Your Pension Wise Appointment'
    expect(deliveries.first.body.encoded).to include 'Your appointment details were updated'
  end
end
