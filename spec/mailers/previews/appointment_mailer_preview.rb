# Preview all emails at http://localhost:3000/rails/mailers/appointment_mailer
class AppointmentMailerPreview < ActionMailer::Preview
  def confirmation
    AppointmentMailer.confirmation(random_appointment)
  end

  def updated
    AppointmentMailer.updated(random_appointment)
  end

  def cancelled
    AppointmentMailer.cancelled(random_appointment)
  end

  private

  def random_appointment
    Appointment.all.sample(1).first || FactoryGirl.create(:appointment)
  end
end
