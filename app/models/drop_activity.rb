class DropActivity < Activity
  def self.from(event, description, appointment)
    create!(
      message: "#{event.humanize} - #{description}",
      appointment: appointment,
      owner: appointment.guider
    ).tap do |activity|
      PusherActivityCreatedJob.perform_later(appointment.guider_id, activity.id)
    end
  end
end
