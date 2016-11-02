class AppointmentMailer < ApplicationMailer
  def confirmation(appointment)
    @appointment = appointment
    mail to: @appointment.email, subject: 'Your Pension Wise Appointment'
  end
end
