class Notifier
  NOTIFY_RESOURCE_MANAGER_ATTRIBUTES = %w[
    first_name
    last_name
    email
    phone
    mobile
    notes
    date_of_birth
    data_subject_consent_obtained
  ].freeze

  def initialize(appointment, modifying_agent = nil)
    @appointment = appointment
    @modifying_agent = modifying_agent
  end

  def call
    return unless appointment.previous_changes

    notify_customer
    notify_guiders
    notify_resource_managers
  end

  private

  def notify_resource_managers
    if appointment_cancelled?
      AppointmentCancelledNotificationsJob.perform_later(appointment)
    elsif appointment_rescheduled?
      AppointmentRescheduledNotificationsJob.perform_later(appointment)
    elsif requires_adjustment_notification?
      AdjustmentNotificationsJob.perform_later(appointment)
    elsif requires_agent_changed_notification?
      AgentChangedNotificationsJob.perform_later(appointment)
    end
  end

  def notify_guiders
    guiders_to_notify.each do |guider_id|
      PusherAppointmentChangedJob.perform_later(guider_id, appointment)
    end
  end

  def guiders_to_notify
    Array(appointment.previous_changes.fetch('guider_id', appointment.guider_id))
  end

  def notify_customer # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    if appointment_cancelled?
      CustomerUpdateJob.perform_later(appointment, CustomerUpdateActivity::CANCELLED_MESSAGE)
    elsif appointment_missed?
      CustomerUpdateJob.perform_later(appointment, CustomerUpdateActivity::MISSED_MESSAGE)
    elsif appointment_details_changed? && appointment.future?
      CustomerUpdateJob.perform_later(appointment, CustomerUpdateActivity::UPDATED_MESSAGE)
    end

    DueDiligenceReferenceNumberJob.perform_now(appointment) if due_diligence_appointment_complete?
    PrintedConfirmationJob.perform_later(appointment) if appointment_rescheduled?
    PrintedThirdPartyConsentFormJob.perform_later(appointment) if requires_printed_consent_form?
    EmailThirdPartyConsentFormJob.perform_later(appointment) if requires_email_consent_form?
    BslCustomerExitPollJob.set(wait: 24.hours).perform_later(appointment) if bsl_appointment_complete?
  end

  def requires_adjustment_notification?
    return unless modifying_agent&.tp_agent?

    appointment.previous_changes.slice('accessibility_requirements', 'third_party_booking').present? &&
      appointment.adjustments?
  end

  def requires_printed_consent_form?
    appointment.previous_changes.slice('printed_consent_form_required').present? &&
      appointment.printed_consent_form_required?
  end

  def requires_email_consent_form?
    appointment.previous_changes.slice('email_consent_form_required', 'email_consent').present? &&
      appointment.email_consent_form_required?
  end

  def bsl_appointment_complete?
    appointment.bsl_video? && appointment_complete?
  end

  def due_diligence_appointment_complete?
    appointment.due_diligence? && appointment_complete?
  end

  def appointment_complete?
    appointment.previous_changes.slice('status').present? &&
      appointment.complete?
  end

  def requires_agent_changed_notification?
    modifying_agent&.tp_agent? && change_notifies_resource_managers?
  end

  def change_notifies_resource_managers?
    appointment.previous_changes.any? &&
      (appointment.previous_changes.keys & NOTIFY_RESOURCE_MANAGER_ATTRIBUTES).present?
  end

  def appointment_details_changed?
    appointment.previous_changes.any? &&
      (appointment.previous_changes.keys - Appointment::NON_NOTIFY_COLUMNS).present?
  end

  def appointment_cancelled?
    appointment.previous_changes.slice('status').present? &&
      appointment.cancelled?
  end

  def appointment_missed?
    appointment.previous_changes.slice('status').present? &&
      appointment.no_show?
  end

  def appointment_rescheduled?
    appointment.previous_changes.slice('guider_id', 'start_at').present?
  end

  attr_reader :appointment, :modifying_agent
end
