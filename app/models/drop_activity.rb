class DropActivity < Activity
  def self.from(event, description, message_type, appointment)
    create!(
      message: "#{event.humanize} - #{description}",
      appointment: appointment,
      owner: owner(appointment, message_type)
    ).tap do |activity|
      PusherHighPriorityCountChangedJob.perform_later(activity.owner)
    end
  end

  def self.owner(appointment, message_type)
    message_type == 'booking_created' ? appointment.agent : appointment.guider
  end

  def pusher_notify_user_ids
    owner_id
  end
end
