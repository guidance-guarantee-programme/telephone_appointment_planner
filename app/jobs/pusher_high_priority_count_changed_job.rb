class PusherHighPriorityCountChangedJob < ApplicationJob
  queue_as :default

  def perform(user)
    Pusher.trigger(
      'telephone_appointment_planner',
      "user_#{user.id}_high_priority_count",
      count: user_high_priority_activity_count(user)
    )
  end

  def user_high_priority_activity_count(user)
    Activity
      .high_priority_for(user)
      .unresolved
      .count
  end
end
