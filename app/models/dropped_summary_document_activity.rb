class DroppedSummaryDocumentActivity < Activity
  MESSAGE = 'fail'.freeze

  after_commit do
    PusherHighPriorityCountChangedJob.perform_later(owner)
  end

  def self.from(appointment)
    create!(
      appointment: appointment,
      owner: appointment.guider,
      message: MESSAGE
    )
  end

  def pusher_notify_user_ids
    owner_id
  end
end
