class PusherNotificationJob < ApplicationJob
  queue_as :default

  def perform(guider_id, appointment)
    Pusher.trigger(
      'telephone_appointment_planner',
      guider_id.to_s,
      customer_name: appointment.name,
      start: appointment.start_at.strftime('%d %B %Y %H:%M'),
      guider_name: appointment.guider.name
    )
  end
end
