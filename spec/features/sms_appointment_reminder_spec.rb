require 'rails_helper'

RSpec.feature 'SMS appointment reminders' do # rubocop:disable Metrics/BlockLength
  scenario 'Executing the SMS appointment reminders job' do
    travel_to '2017-11-28 08:00 UTC' do
      given_appointments_due_sms_reminders_exist
      when_the_task_is_executed
      then_the_required_jobs_are_scheduled
    end
  end

  def given_appointments_due_sms_reminders_exist
    @agent = create(:resource_manager)
    # past the reminder window
    @past = create(:appointment, start_at: 5.days.from_now)
    # in the window but no mobile number
    @no_mobile = create(:appointment, mobile: '', start_at: 2.days.from_now, agent: @agent)
    # in the window but the 'mobile' number is not valid UK
    @no_uk_mobile = create(:appointment, mobile: '0121 123 4567', start_at: 2.days.from_now, agent: @agent)
    # in the window with a mobile number
    @mobile = create(:appointment, start_at: 2.days.from_now, agent: @agent)
    @other_mobile = create(:appointment, mobile: '', phone: '+447715930459', start_at: 2.days.from_now, agent: @agent)
    @another_mobile = create(:appointment, mobile: '00447715930459', start_at: 2.days.from_now, agent: @agent)
  end

  def when_the_task_is_executed
    @job_class = double(SmsAppointmentReminderJob, perform_later: true)

    SmsAppointmentReminders.new(@job_class).call
  end

  def then_the_required_jobs_are_scheduled
    expect(@job_class).to have_received(:perform_later).exactly(3).times

    [@mobile, @other_mobile, @another_mobile].each do |appointment|
      expect(@job_class).to have_received(:perform_later).with(appointment)
    end
  end
end
