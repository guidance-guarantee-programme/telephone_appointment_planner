class AppointmentReminderJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    ReminderActivity.create!(
      appointment: appointment,
      owner: appointment.guider
    )
    AppointmentMailer.reminder(appointment).deliver_later
  end
end
