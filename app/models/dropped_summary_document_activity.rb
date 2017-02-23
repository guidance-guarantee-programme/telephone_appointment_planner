class DroppedSummaryDocumentActivity < Activity
  def self.from(appointment)
    create!(
      appointment: appointment,
      owner: appointment.guider,
      message: 'fail'
    ).tap do |activity|
      PusherActivityNotificationJob.perform_later(appointment.guider_id, activity.id)
    end
  end
end
