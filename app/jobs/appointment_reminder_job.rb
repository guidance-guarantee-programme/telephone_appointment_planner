class AppointmentReminderJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    ReminderActivity.create!(
      appointment: appointment,
      owner: appointment.guider,
      message: 'sent a reminder'
    )
    AppointmentMailer.reminder(appointment).deliver_later
  end
end
