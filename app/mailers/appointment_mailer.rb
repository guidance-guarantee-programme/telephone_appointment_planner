class AppointmentMailer < ApplicationMailer
  def resource_manager_appointment_rescheduled(appointment, recipient)
    mailgun_headers('resource_manager_appointment_rescheduled', appointment.id)
    @appointment = decorate(appointment)
    mail to: recipient, subject: @appointment.subject('Appointment Rescheduled'), from: @appointment.from
  end

  def resource_manager_appointment_cancelled(appointment, recipient)
    mailgun_headers('resource_manager_appointment_cancelled', appointment.id)
    @appointment = decorate(appointment)
    mail to: recipient, subject: @appointment.subject('Appointment Cancelled'), from: @appointment.from
  end

  def resource_manager_appointment_created(appointment, recipient)
    mailgun_headers('resource_manager_appointment_created', appointment.id)
    @appointment = decorate(appointment)
    mail to: recipient, subject: @appointment.subject('Appointment Created'), from: @appointment.from
  end

  def adjustment(appointment, recipient)
    mailgun_headers('adjustment', appointment.id)
    @appointment = decorate(appointment)
    mail to: recipient, subject: @appointment.subject('Appointment Adjustment'), from: @appointment.from
  end

  def confirmation(appointment)
    return unless appointment.email?

    mailgun_headers('booking_created', appointment.id)
    @appointment = decorate(appointment)
    mail to: @appointment.email, subject: @appointment.subject, from: @appointment.from
  end

  def updated(appointment)
    return unless appointment.email?

    mailgun_headers('booking_updated', appointment.id)
    @appointment = decorate(appointment)
    mail to: @appointment.email, subject: @appointment.subject, from: @appointment.from
  end

  def reminder(appointment)
    return unless appointment.email?

    mailgun_headers('booking_reminder', appointment.id)
    @appointment = decorate(appointment)
    mail to: @appointment.email, subject: @appointment.subject, from: @appointment.from
  end

  def cancelled(appointment)
    return unless appointment.email?

    mailgun_headers('booking_cancelled', appointment.id)
    @appointment = decorate(appointment)
    mail to: @appointment.email, subject: @appointment.subject, from: @appointment.from
  end

  def missed(appointment)
    return unless appointment.email?

    mailgun_headers('booking_missed', appointment.id)
    @appointment = decorate(appointment)
    mail to: @appointment.email, subject: @appointment.subject, from: @appointment.from
  end

  def bsl_customer_exit_poll(appointment)
    return unless appointment.email?

    mailgun_headers('bsl_exit_poll', appointment.id)
    @appointment = decorate(appointment)
    mail to: @appointment.email, subject: @appointment.subject, from: @appointment.from
  end

  def consent_form(appointment)
    return unless appointment.email_consent?

    mailgun_headers('consent_form', appointment.id)
    @appointment = decorate(appointment)
    mail to: @appointment.email_consent, subject: 'Pension Wise Third Party Consent Form', from: @appointment.from
  end

  private

  def decorate(appointment)
    AppointmentEmailPresenter.new(appointment)
  end
end
