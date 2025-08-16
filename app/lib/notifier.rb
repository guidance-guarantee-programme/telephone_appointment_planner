# rubocop:disable Metrics/ClassLength
class Notifier
  NOTIFY_RESOURCE_MANAGER_ATTRIBUTES = %w[
    first_name
    last_name
    email
    phone
    mobile
    notes
    date_of_birth
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
    notify_casebook
    notify_calendar_alterations
  end

  private

  def notify_calendar_alterations
    return unless status_changed? || appointment_reallocated?

    PusherAppointmentCalendarAlterationsJob.perform_later(appointment)
  end

  def notify_casebook
    if appointment_cancelled?
      CancelCasebookAppointmentJob.perform_later(appointment)
    elsif appointment_reallocated?
      RescheduleCasebookAppointmentJob.perform_later(appointment)
    end
  end

  def notify_resource_managers
    if appointment_cancelled?
      AppointmentCancelledNotificationsJob.perform_later(appointment)
    elsif appointment_reallocated?
      AppointmentRescheduledNotificationsJob.perform_later(appointment)
    end

    AdjustmentNotificationsJob.perform_later(appointment) if requires_adjustment_notification?
    AgentChangedNotificationsJob.perform_later(appointment) if requires_agent_changed_notification?

    AppointmentMailer.potential_duplicates(appointment).deliver_later if requires_potential_duplicates_notification?
  end

  def notify_guiders
    SummaryDocumentCheckJob.set(wait: 24.hours).perform_later(appointment) if appointment_complete?

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
    BslCustomerExitPollJob.set(wait: 24.hours).perform_later(appointment) if bsl_appointment_complete?
  end

  def requires_potential_duplicates_notification?
    appointment.pending? && appointment.potential_duplicates?
  end

  def requires_adjustment_notification?
    return unless modifying_agent&.tpas_agent?

    appointment.previous_changes.slice(
      'accessibility_requirements', 'third_party_booking', 'dc_pot_confirmed'
    ).present? && appointment.adjustments?
  end

  def bsl_appointment_complete?
    appointment.bsl_video? && appointment_complete?
  end

  def due_diligence_appointment_complete?
    appointment.due_diligence? && appointment_complete?
  end

  def appointment_complete?
    status_changed? && appointment.complete?
  end

  def requires_agent_changed_notification?
    !appointment.guider.tpas? && modifying_agent&.tpas_agent? && change_notifies_resource_managers?
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
    status_changed? && appointment.cancelled?
  end

  def appointment_missed?
    status_changed? && appointment.no_show?
  end

  def appointment_reallocated?
    appointment.previous_changes.slice('guider_id', 'start_at').present?
  end

  def appointment_rescheduled?
    appointment.previous_changes.slice('start_at').present?
  end

  def status_changed?
    appointment.previous_changes.slice('status').present?
  end

  attr_reader :appointment, :modifying_agent
end
# rubocop:enable Metrics/ClassLength
