class AppointmentUpdatedNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(appointment)
    AppointmentMailer.updated(appointment).deliver unless appointment.in_the_past?

    activity = CustomerUpdateActivity.from(appointment)

    PusherActivityNotificationJob.perform_later(appointment.guider_id, activity.id)
  end
end
