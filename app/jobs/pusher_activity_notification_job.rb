class PusherActivityNotificationJob < ApplicationJob
  queue_as :default

  include Rails.application.routes.url_helpers

  def perform(recipient, activity)
    Pusher.trigger(
      'telephone_appointment_planner',
      "guider_activity_#{recipient.id}",
      body: render_activity(activity, true)
    )
    Pusher.trigger(
      'telephone_appointment_planner',
      "appointment_activity_#{activity.appointment.id}",
      body: render_activity(activity, false)
    )
  end

  private

  def render_activity(activity, details)
    ApplicationController.render(
      partial: activity,
      locals: { details: details, hide: false }
    )
  end
end
