class DropActivity < Activity
  def self.from(event, description, message_type, appointment)
    create!(
      message: "#{event.humanize} - #{description}",
      appointment:,
      owner: owner(appointment, message_type)
    ).tap do |activity|
      PusherHighPriorityCountChangedJob.perform_later(activity.owner) if activity.owner
    end
  end

  def self.from_invalid_email(appointment)
    from('undeliverable', 'The email is invalid', 'booking_created', appointment)
  end

  def self.owner(appointment, message_type)
    appointment.agent if message_type == 'booking_created'
  end

  def owner_required?
    false
  end
end
