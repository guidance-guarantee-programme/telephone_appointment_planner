class DropActivity < Activity
  after_commit do
    PusherHighPriorityCountChangedJob.perform_later(owner)

    unless appointment.agent_is_pension_wise_api?
      PusherHighPriorityCountChangedJob.perform_later(appointment.agent)
    end
  end

  def self.from(event, description, appointment)
    create!(
      message: "#{event.humanize} - #{description}",
      appointment: appointment,
      owner: appointment.guider
    )
  end

  def pusher_notify_user_ids
    owner_id
  end
end
