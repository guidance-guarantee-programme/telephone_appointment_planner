class AppointmentRemindersJob < ApplicationJob
  queue_as :default

  def perform
    Appointment.pending.within_reminder_window.each do |appointment|
      sent_in_current_period = ReminderActivity.exists?(
        appointment: appointment,
        created_at: 12.hours.ago..12.hours.from_now
      )
      AppointmentReminderJob.perform_later(appointment) unless sent_in_current_period
    end
  end
end
