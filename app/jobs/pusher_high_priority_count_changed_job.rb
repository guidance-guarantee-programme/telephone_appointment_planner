class PusherHighPriorityCountChangedJob < ApplicationJob
  queue_as :default

  def perform(guider)
    Pusher.trigger(
      'telephone_appointment_planner',
      "guider_#{guider.id}_high_priority_count",
      count: guider_high_priority_activity_count(guider)
    )
  end

  def guider_high_priority_activity_count(guider)
    guider
      .activities
      .high_priority
      .unresolved
      .count
  end
end
