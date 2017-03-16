class CustomerUpdateJob < ActiveJob::Base
  queue_as :default

  def perform(appointment, message)
    send_email(appointment, message)

    activity = CustomerUpdateActivity.from(appointment, message)

    PusherActivityNotificationJob.perform_later(appointment.guider_id, activity.id)
  end

  private

  def send_email(appointment, message)
    case message
    when CustomerUpdateActivity::CANCELLED_MESSAGE
      AppointmentMailer.cancelled(appointment).deliver
    when CustomerUpdateActivity::CONFIRMED_MESSAGE
      AppointmentMailer.confirmation(appointment).deliver
    when CustomerUpdateActivity::MISSED_MESSAGE
      AppointmentMailer.missed(appointment).deliver
    when CustomerUpdateActivity::UPDATED_MESSAGE
      AppointmentMailer.updated(appointment).deliver
    end
  end
end
