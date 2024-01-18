class CustomerUpdateJob < ApplicationJob
  queue_as :default

  def perform(appointment, message)
    return unless appointment.email?

    result = send_email(appointment, message)

    CustomerUpdateActivity.from(appointment, message) if result
  rescue Net::SMTPSyntaxError
    DropActivity.from_invalid_email(appointment)
  end

  private

  def send_email(appointment, message) # rubocop:disable Metrics/MethodLength
    case message
    when CustomerUpdateActivity::CANCELLED_MESSAGE
      AppointmentMailer.cancelled(appointment).deliver_now
    when CustomerUpdateActivity::CONFIRMED_MESSAGE
      AppointmentMailer.confirmation(appointment).deliver_now
    when CustomerUpdateActivity::MISSED_MESSAGE
      AppointmentMailer.missed(appointment).deliver_now
    when CustomerUpdateActivity::UPDATED_MESSAGE
      return false unless appointment.pending?

      AppointmentMailer.updated(appointment).deliver_now
    end

    true
  end
end
