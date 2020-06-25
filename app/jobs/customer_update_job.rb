class CustomerUpdateJob < ActiveJob::Base
  queue_as :default

  def perform(appointment, message)
    return unless appointment.email?

    send_email(appointment, message)

    CustomerUpdateActivity.from(appointment, message)
  rescue Net::SMTPSyntaxError
    DropActivity.from_invalid_email(appointment)
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
