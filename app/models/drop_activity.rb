class DropActivity < Activity
  def self.from(event, description, appointment)
    create!(
      message: "#{event.humanize} - #{description}",
      appointment: appointment,
      owner: appointment.guider
    ).tap do |activity|
      PusherActivityNotificationJob.perform_later(appointment.guider, activity)
    end
  end
end
