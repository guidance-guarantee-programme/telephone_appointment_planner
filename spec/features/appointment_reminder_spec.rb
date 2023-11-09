require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.feature 'Appointment reminders' do
  scenario 'when less than 48 hours before the appointment it sends a reminder' do
    given_it_is_a_monday_not_near_a_bank_holiday do
      and_an_appointment_exists

      when_it_is_less_than_48_hours_before_the_appointment do
        and_the_reminder_job_runs
        then_no_email_reminder_is_delivered
        and_no_reminder_activity_is_logged
      end
    end
  end

  def given_it_is_a_monday_not_near_a_bank_holiday
    travel_to Time.zone.parse('2016-06-13 12:00')

    yield

    travel_back
  end

  def and_an_appointment_exists
    @start_at = Time.zone.parse('2016-06-20 12:00')
    @appointment = create(:appointment, start_at: @start_at)
  end

  def when_it_is_less_than_48_hours_before_the_appointment
    travel_to Time.zone.parse('2016-06-18 11:55')

    yield

    travel_back
  end

  def and_the_reminder_job_runs
    AppointmentRemindersJob.new.perform
  end

  def then_no_email_reminder_is_delivered
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  def and_no_reminder_activity_is_logged
    expect(@appointment.activities.where(type: 'ReminderActivity'))
      .to be_empty
  end
end
# rubocop:enable Metrics/BlockLength
