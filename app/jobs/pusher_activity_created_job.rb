class PusherActivityCreatedJob < ApplicationJob
  queue_as :default

  include Rails.application.routes.url_helpers

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    Bugsnag.notify(exception)

    retry_job(wait: 2.seconds)
  end

  def perform(activity_id)
    activity = Activity.find(activity_id)

    notify_appointment_feed(activity)
  end

  private

  def notify_appointment_feed(activity)
    Pusher.trigger(
      'telephone_appointment_planner',
      "appointment_activity_#{activity.appointment.id}",
      body: render_activity(activity, false)
    )
  end

  def render_activity(activity, details)
    ApplicationController.render(
      partial: activity,
      locals: { details: details, hide: false }
    )
  end
end
