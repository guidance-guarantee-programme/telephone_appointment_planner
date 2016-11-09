class CreateActivity < Activity
  def self.from(audit, appointment)
    activity = create!(
      user_id: audit.user_id,
      message: 'created this appointment',
      appointment_id: appointment.id,
      owner_id: appointment.guider.id
    )
    PusherActivityNotificationJob.perform_later(appointment.guider, activity)
  end
end
