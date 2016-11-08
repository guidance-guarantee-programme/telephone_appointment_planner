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
    return unless appointment.previous_changes.slice('start_at', 'end_at').present?

    AppointmentMailer.updated(appointment).deliver_later
  end

  attr_reader :appointment
end
