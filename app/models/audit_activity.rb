class AuditActivity < Activity
  def self.from(audit, appointment)
    activity = create!(
      user_id: audit.user_id,
      owner_id: appointment.guider.id,
      message: audit.audited_changes.keys.map(&:humanize).to_sentence.downcase,
      appointment_id: appointment.id
    )
    PusherActivityNotificationJob.perform_later(appointment.guider, activity)
  end
end
