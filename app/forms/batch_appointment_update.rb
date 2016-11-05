class BatchAppointmentUpdate
  def initialize(changes)
    @changes = JSON.parse(changes)
  end

  def call
    changes.each do |change|
      appointment = update_appointment(change)
      send_notifications(appointment)
    end
  end

  private

  def send_notifications(appointment)
    return unless appointment.previous_changes

    notify_customer(appointment)
    notify_guiders(appointment)
  end

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

    AppointmentMailer.updated(appointment).deliver_later if appointment.email.present?
  end

  def update_appointment(change)
    Appointment.find(change['id']).tap do |appointment|
      appointment.assign_attributes(permitted_attributes(change))
      appointment.save!
    end
  end

  def permitted_attributes(change)
    change.slice('guider_id', 'start_at', 'end_at')
  end

  attr_reader :changes
end
