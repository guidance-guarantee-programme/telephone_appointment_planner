# Preview all emails at http://localhost:3000/rails/mailers/appointment_mailer
class AppointmentMailerPreview < ActionMailer::Preview
  def confirmation
    appointment = FactoryGirl.create(:appointment)
    AppointmentMailer.confirmation(appointment)
  end
end
