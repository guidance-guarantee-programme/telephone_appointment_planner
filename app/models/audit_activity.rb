class AuditActivity < Activity
  def self.from(audit, appointment)
    return if only_the_guider_has_been_changed?(audit)

    activity = create!(
      user_id: audit.user_id,
      owner_id: appointment.guider.id,
      message: audit.audited_changes.keys.map(&:humanize).to_sentence.downcase,
      appointment_id: appointment.id
    )
    PusherActivityNotificationJob.perform_later(appointment.guider, activity)
  end

  def self.only_the_guider_has_been_changed?(audit)
    audit.audited_changes.keys == ['guider_id']
  end
end
