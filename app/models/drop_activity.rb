class DropActivity < Activity
  def self.from(event, description, message_type, appointment)
    create!(
      message: "#{event.humanize} - #{description}",
      appointment: appointment,
      owner: owner(appointment, message_type)
    ).tap do |activity|
      PusherHighPriorityCountChangedJob.perform_later(activity.owner) if activity.owner
    end
  end

  def self.owner(appointment, message_type)
    return appointment.agent if message_type == 'booking_created'
  end

  def pusher_notify_user_ids
    owner_id
  end

  def owner_required?
    false
  end
end
