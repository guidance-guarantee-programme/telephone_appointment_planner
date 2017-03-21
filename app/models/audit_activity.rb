class AuditActivity < Activity
  def self.from(audit, appointment)
    return if only_the_guider_has_been_changed?(audit)

    activity = create!(
      user_id: audit.user_id,
      owner_id: appointment.guider.id,
      message: audit.audited_changes.keys.map(&:humanize).to_sentence.downcase,
      appointment_id: appointment.id
    )

    PusherActivityCreatedJob.perform_later(appointment.guider_id, activity.id)
  end

  def self.only_the_guider_has_been_changed?(audit)
    audit.audited_changes.keys == ['guider_id']
  end
end
