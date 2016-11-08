class PusherActivityNotificationJob < ApplicationJob
  queue_as :default

  def perform(recipient, activity)
    Pusher.trigger(
      'telephone_appointment_planner',
      "guider_activity_#{recipient.id}",
      body: render_activity(activity)
    )
    Pusher.trigger(
      'telephone_appointment_planner',
      "appointment_activity_#{activity.appointment.id}",
      body: render_activity(activity)
    )
  end

  private

  def render_activity(activity)
    ApplicationController.new.render_to_string(
      partial: activity
    )
  end
end
