# Preview all emails at http://localhost:3000/rails/mailers/appointment_mailer
class AppointmentMailerPreview < ActionMailer::Preview
<<<<<<< HEAD
  def resource_manager_email_dropped
    appointment = random_appointment

    AppointmentMailer.resource_manager_email_dropped(
=======
  def resource_manager_appointment_changed
    appointment = random_appointment

    appointment.update_attribute(:first_name, 'Benjamin')

    AppointmentMailer.resource_manager_appointment_changed(
>>>>>>> 298653f (Notify resource managers when appointments change)
      appointment,
      appointment.resource_managers.first.email
    )
  end

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

  def adjustment
    appointment = random_appointment

    AppointmentMailer.adjustment(appointment, appointment.resource_managers.first)
  end

  def due_diligence_confirmation
    AppointmentMailer.confirmation(random_due_diligence_appointment)
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

  def consent_form
    AppointmentMailer.consent_form(
      FactoryBot.build_stubbed(:appointment, :third_party_booking, :email_consent_form_requested)
    )
  end

  def bsl_customer_exit_poll
    AppointmentMailer.bsl_customer_exit_poll(random_appointment)
  end

  private

  def random_appointment
    Appointment.all.sample(1).first || FactoryBot.create(:appointment)
  end

  def random_due_diligence_appointment
    Appointment.where(schedule_type: 'due_diligence').sample(1).first || FactoryBot.create(:appointment, :due_diligence)
  end
end
