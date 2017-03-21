class CreateActivity < Activity
  def self.from(audit, appointment)
    activity = create!(
      user_id: audit.user_id,
      appointment_id: appointment.id,
      owner_id: appointment.guider.id
    )

    PusherActivityCreatedJob.perform_later(appointment.guider_id, activity.id)
  end
end
