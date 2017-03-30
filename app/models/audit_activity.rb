class AuditActivity < Activity
  def self.from(audit, appointment)
    return if only_the_guider_has_been_changed?(audit)

    create!(
      user_id: audit.user_id,
      owner_id: appointment.guider.id,
      message: audit.audited_changes.keys.map(&:humanize).to_sentence.downcase,
      appointment_id: appointment.id
    )
  end

  def self.only_the_guider_has_been_changed?(audit)
    audit.audited_changes.keys == ['guider_id']
  end

  def pusher_notify_user_ids
    owner_id
  end
end
