class DroppedSummaryDocumentActivity < Activity
  def self.from(appointment)
    create!(
      appointment: appointment,
      owner: appointment.guider,
      message: 'fail'
    ).tap do |activity|
      PusherActivityCreatedJob.perform_later(appointment.guider_id, activity.id)
    end
  end
end
