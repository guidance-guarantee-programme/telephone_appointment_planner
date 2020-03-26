# Preview all emails at http://localhost:3000/rails/mailers/appointment_mailer
class AppointmentMailerPreview < ActionMailer::Preview
  def resource_manager_appointment_created
    appointment = random_appointment

    AppointmentMailer.resource_manager_appointment_created(
      appointment,
      appointment.resource_managers.first.email
    )
  end

  def resource_manager_appointment_rescheduled
    appointment = random_appointment

    AppointmentMailer.resource_manager_appointment_rescheduled(
      appointment,
      appointment.resource_managers.first.email
    )
  end

  def resource_manager_appointment_cancelled
    appointment = random_appointment

    AppointmentMailer.resource_manager_appointment_cancelled(
      appointment,
      appointment.resource_managers.first.email
    )
  end

  def accessibility_adjustment
    appointment = random_appointment

    AppointmentMailer.accessibility_adjustment(appointment, appointment.resource_managers.first)
  end

  def confirmation
    AppointmentMailer.confirmation(random_appointment)
  end

  def updated
    AppointmentMailer.updated(random_appointment)
  end

  def cancelled
    AppointmentMailer.cancelled(random_appointment)
  end

  def missed
    AppointmentMailer.missed(random_appointment)
  end

  def reminder
    AppointmentMailer.reminder(random_appointment)
  end

  private

  def random_appointment
    Appointment.all.sample(1).first || FactoryBot.create(:appointment)
  end
end
