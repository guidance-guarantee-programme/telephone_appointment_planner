class SmsAppointmentReminders
  def initialize(job_class = SmsAppointmentReminderJob)
    @job_class = job_class
  end

  def call
    Appointment.needing_sms_reminder.find_each do |appointment|
      job_class.perform_later(appointment)
    end
  end

  private

  attr_reader :job_class
end
