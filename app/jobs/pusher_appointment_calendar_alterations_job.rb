class PusherAppointmentCalendarAlterationsJob < ApplicationJob
  queue_as :default

  def perform(appointment, modifying_agent)
    trigger_notification(
      "#{appointment.start_at.to_date}-#{appointment.guider.organisation_content_id}",
      modifying_agent
    )

    return unless (@changes = appointment.previous_changes['start_at'])
    return unless @changes.first

    trigger_notification(
      "#{@changes.first.to_date}-#{appointment.guider.organisation_content_id}",
      modifying_agent
    )
  end

  private

  def trigger_notification(key, modifying_agent)
    Pusher.trigger(
      'telephone_appointment_planner',
      key,
      refresh: true,
      ownerId: modifying_agent&.uid
    )
  end
end
