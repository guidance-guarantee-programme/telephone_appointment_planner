class AppointmentStatusReminderJob < ApplicationJob
  queue_as :default

  def perform
    Appointment.needing_status_reminder.each do |appointment|
      AppointmentMailer.guider_status_reminder(appointment).deliver_later

      appointment.without_auditing do
        appointment.update_attribute(:status_reminder_sent, true) # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
