class AppointmentMailer < ApplicationMailer
  rescue_from Net::SMTPUnknownError do |exception|
    Rails.logger.error(exception)
  end

  default subject: -> { @appointment.subject }, from: -> { @appointment.from }

  def resource_manager_email_dropped(appointment, recipient)
    mailgun_headers('resource_manager_email_dropped', appointment.id)
    @appointment = decorate(appointment)
    mail to: recipient, subject: @appointment.subject('Email Failure')
  end

  def resource_manager_appointment_changed(appointment, recipient)
    mailgun_headers('resource_manager_appointment_changed', appointment.id)
    @appointment = decorate(appointment)
    mail to: recipient, subject: @appointment.subject('Appointment Updated')
  end

  def resource_manager_appointment_rescheduled(appointment, recipient)
    mailgun_headers('resource_manager_appointment_rescheduled', appointment.id)
    @appointment = decorate(appointment)
    mail to: recipient, subject: @appointment.subject('Appointment Rescheduled')
  end

  def resource_manager_appointment_cancelled(appointment, recipient)
    mailgun_headers('resource_manager_appointment_cancelled', appointment.id)
    @appointment = decorate(appointment)
    mail to: recipient, subject: @appointment.subject('Appointment Cancelled')
  end

  def resource_manager_appointment_created(appointment, recipient)
    mailgun_headers('resource_manager_appointment_created', appointment.id)
    @appointment = decorate(appointment)
    mail to: recipient, subject: @appointment.subject('Appointment Created')
  end

  def potential_duplicates(appointment)
    mailgun_headers('potential_duplicates', appointment.id)
    @appointment = decorate(appointment)
    mail to: ApplicationJob::OPS_SUPERVISOR, subject: @appointment.subject('Potential Duplicates')
  end

  def adjustment(appointment, recipient)
    return unless appointment.adjustments?

    mailgun_headers('adjustment', appointment.id)
    @appointment = decorate(appointment)
    mail to: recipient, subject: @appointment.subject('Appointment Adjustment')
  end

  def confirmation(appointment)
    return unless appointment.email?

    mailgun_headers('booking_created', appointment.id)
    @appointment = decorate(appointment)
    mail to: @appointment.email
  end

  def updated(appointment)
    return unless appointment.email?

    mailgun_headers('booking_updated', appointment.id)
    @appointment = decorate(appointment)
    mail to: @appointment.email
  end

  def reminder(appointment)
    return unless appointment.email?

    mailgun_headers('booking_reminder', appointment.id)
    @appointment = decorate(appointment)
    mail to: @appointment.email
  end

  def cancelled(appointment)
    return unless appointment.email?

    mailgun_headers('booking_cancelled', appointment.id)
    @appointment = decorate(appointment)
    mail to: @appointment.email
  end

  def missed(appointment)
    return unless appointment.email?

    mailgun_headers('booking_missed', appointment.id)
    @appointment = decorate(appointment)
    mail to: @appointment.email
  end

  def bsl_customer_exit_poll(appointment)
    return unless appointment.email?

    mailgun_headers('bsl_exit_poll', appointment.id)
    @appointment = decorate(appointment)
    mail to: @appointment.email
  end

  def consent_form(appointment)
    return unless appointment.email_consent?

    mailgun_headers('consent_form', appointment.id)
    @appointment = decorate(appointment)
    mail to: @appointment.email_consent, subject: 'Pension Wise Third Party Consent Form'
  end

  private

  def decorate(appointment)
    AppointmentEmailPresenter.new(appointment)
  end
end
