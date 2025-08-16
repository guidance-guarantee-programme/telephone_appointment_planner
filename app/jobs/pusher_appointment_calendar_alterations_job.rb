class PusherAppointmentCalendarAlterationsJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    trigger_notification("#{appointment.start_at.to_date}-#{appointment.guider.organisation_content_id}")

    return unless (@changes = appointment.previous_changes['start_at'])
    return unless @changes.first

    trigger_notification("#{@changes.first.to_date}-#{appointment.guider.organisation_content_id}")
  end

  private

  def trigger_notification(key)
    Pusher.trigger('telephone_appointment_planner', key, refresh: true)
  end
end
