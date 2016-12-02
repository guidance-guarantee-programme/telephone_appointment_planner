class AppointmentMailer < ApplicationMailer
  default subject: 'Your Pension Wise Appointment'

  def confirmation(appointment)
    return unless appointment.email?

    mailgun_headers('booking_created', appointment.id)
    @appointment = appointment
    mail to: @appointment.email
  end

  def updated(appointment)
    return unless appointment.email?

    mailgun_headers('booking_updated', appointment.id)
    @appointment = appointment
    mail to: @appointment.email
  end

  def cancelled(appointment)
    return unless appointment.email?

    mailgun_headers('booking_cancelled', appointment.id)
    @appointment = appointment
    mail to: @appointment.email
  end

  def missed(appointment)
    return unless appointment.email?

    mailgun_headers('booking_missed', appointment.id)
    @appointment = appointment
    mail to: @appointment.email
  end
end
