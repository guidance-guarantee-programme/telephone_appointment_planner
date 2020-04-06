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
end
