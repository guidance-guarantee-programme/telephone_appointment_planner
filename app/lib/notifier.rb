class Notifier
  def initialize(appointment)
    @appointment = appointment
  end

  def call
    return unless appointment.previous_changes

    notify_customer
    notify_guiders
  end

  private

  def notify_guiders
    guiders_to_notify.each do |guider_id|
      PusherAppointmentChangedJob.perform_later(guider_id, appointment)
    end
  end

  def guiders_to_notify
    Array(appointment.previous_changes.fetch('guider_id', appointment.guider_id))
  end

  def notify_customer
    if appointment_cancelled?
      CustomerUpdateJob.perform_later(appointment, CustomerUpdateActivity::CANCELLED_MESSAGE)
    elsif appointment_missed?
      CustomerUpdateJob.perform_later(appointment, CustomerUpdateActivity::MISSED_MESSAGE)
    elsif appointment_details_changed? && appointment.future?
      CustomerUpdateJob.perform_later(appointment, CustomerUpdateActivity::UPDATED_MESSAGE)
    end
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

  attr_reader :appointment
end
