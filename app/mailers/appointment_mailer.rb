class AppointmentMailer < ApplicationMailer
  def resource_manager_appointment_rescheduled(appointment, recipient)
    mailgun_headers('resource_manager_appointment_rescheduled', appointment.id)
    @appointment = appointment
    mail to: recipient, subject: subject_for(@appointment, 'Appointment Rescheduled'), from: from_for(@appointment)
  end

  def resource_manager_appointment_cancelled(appointment, recipient)
    mailgun_headers('resource_manager_appointment_cancelled', appointment.id)
    @appointment = appointment
    mail to: recipient, subject: subject_for(@appointment, 'Appointment Cancelled'), from: from_for(@appointment)
  end

  def resource_manager_appointment_created(appointment, recipient)
    mailgun_headers('resource_manager_appointment_created', appointment.id)
    @appointment = appointment
    mail to: recipient, subject: subject_for(@appointment, 'Appointment Created'), from: from_for(@appointment)
  end

  def adjustment(appointment, recipient)
    mailgun_headers('adjustment', appointment.id)
    @appointment = appointment
    mail to: recipient, subject: subject_for(@appointment, 'Appointment Adjustment'), from: from_for(@appointment)
  end

  def confirmation(appointment)
    return unless appointment.email?

    mailgun_headers('booking_created', appointment.id)
    @appointment = appointment
    mail to: @appointment.email, subject: subject_for(@appointment), from: from_for(@appointment)
  end

  def updated(appointment)
    return unless appointment.email?

    mailgun_headers('booking_updated', appointment.id)
    @appointment = appointment
    mail to: @appointment.email, subject: subject_for(@appointment), from: from_for(@appointment)
  end

  def reminder(appointment)
    return unless appointment.email?

    mailgun_headers('booking_reminder', appointment.id)
    @appointment = appointment
    mail to: @appointment.email, subject: subject_for(@appointment), from: from_for(@appointment)
  end

  def cancelled(appointment)
    return unless appointment.email?

    mailgun_headers('booking_cancelled', appointment.id)
    @appointment = appointment
    mail to: @appointment.email, subject: subject_for(@appointment), from: from_for(@appointment)
  end

  def missed(appointment)
    return unless appointment.email?

    mailgun_headers('booking_missed', appointment.id)
    @appointment = appointment
    mail to: @appointment.email, subject: subject_for(@appointment), from: from_for(@appointment)
  end

  def bsl_customer_exit_poll(appointment)
    return unless appointment.email?

    mailgun_headers('bsl_exit_poll', appointment.id)
    @appointment = appointment
    mail to: @appointment.email, subject: subject_for(@appointment), from: from_for(@appointment)
  end

  def consent_form(appointment)
    return unless appointment.email_consent?

    mailgun_headers('consent_form', appointment.id)
    @appointment = appointment
    mail to: @appointment.email_consent, subject: 'Pension Wise Third Party Consent Form', from: from_for(@appointment)
  end

  private

  def subject_for(appointment, suffix = 'Appointment')
    "#{type_for(appointment)} #{suffix}"
  end

  def from_for(appointment)
    "#{type_for(appointment)} Bookings <booking.pensionwise@moneyhelper.org.uk>"
  end

  def type_for(appointment)
    appointment.due_diligence? ? 'Pension Safeguarding Guidance' : 'Pension Wise'
  end
end
