class AppointmentMailer < ApplicationMailer
  default subject: 'Your Pension Wise Appointment'

  def confirmation(appointment)
    return unless appointment.email?

    @appointment = appointment
    mail to: @appointment.email
  end

  def updated(appointment)
    return unless appointment.email?

    @appointment = appointment
    mail to: @appointment.email
  end
end
