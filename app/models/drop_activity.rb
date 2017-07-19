class DropActivity < Activity
  def self.from(event, description, appointment)
    create!(
      message: "#{event.humanize} - #{description}",
      appointment: appointment,
      owner: appointment.agent
    ).tap do |activity|
      PusherHighPriorityCountChangedJob.perform_later(activity.owner)
    end
  end

  def pusher_notify_user_ids
    owner_id
  end
end
