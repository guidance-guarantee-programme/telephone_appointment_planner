class Notifier
  def initialize(appointment)
    @appointment = appointment
  end

  def call
    return unless appointment.previous_changes

    notify_customer(appointment)
    notify_guiders(appointment)
  end

  private

  def notify_guiders(appointment)
    guiders_to_notify(appointment).each do |guider_id|
      PusherNotificationJob.perform_later(guider_id, appointment)
    end
  end

  def guiders_to_notify(appointment)
    Array(appointment.previous_changes.fetch('guider_id', appointment.guider_id))
  end

  def notify_customer(appointment)
    if appointment_details_changed?(appointment)
      AppointmentUpdatedNotificationJob.perform_later(appointment)
    elsif appointment_cancelled?(appointment)
      AppointmentMailer.cancelled(appointment).deliver_later
    elsif appointment_missed?(appointment)
      AppointmentMailer.missed(appointment).deliver_later
    end
  end

  def appointment_details_changed?(appointment)
    appointment.previous_changes.any? &&
      (appointment.previous_changes.keys - Appointment::NON_NOTIFY_COLUMNS).present?
  end

  def appointment_cancelled?(appointment)
    appointment.previous_changes.slice('status').present? &&
      appointment.cancelled?
  end

  def appointment_missed?(appointment)
    appointment.previous_changes.slice('status').present? &&
      appointment.no_show?
  end

  attr_reader :appointment
end
