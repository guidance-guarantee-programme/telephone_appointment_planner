require 'rails_helper'

RSpec.feature 'Appointment reminders' do
  scenario 'when less than 48 hours before the appointment it sends a reminder' do
    travel_to Time.zone.parse('2016-06-13 12:00') do
      given_an_appointment_exists

      travel_to Time.zone.parse('2016-06-18 11:55') do
        when_the_reminder_job_runs
        then_no_email_reminder_is_delivered
        and_no_reminder_activity_is_logged
      end
    end
  end

  def given_an_appointment_exists
    @start_at = Time.zone.parse('2016-06-20 12:00')
    @appointment = create(:appointment, start_at: @start_at)
  end

  def when_the_reminder_job_runs
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
