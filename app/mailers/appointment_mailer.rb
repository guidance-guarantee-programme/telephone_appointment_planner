class AppointmentMailer < ApplicationMailer
  default subject: 'Your Pension Wise Appointment'

  def confirmation(appointment)
    @appointment = appointment
    mail to: @appointment.email
  end

  def updated(appointment)
    @appointment = appointment
    mail to: @appointment.email
  end
end
