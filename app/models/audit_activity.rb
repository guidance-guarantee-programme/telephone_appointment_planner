class AuditActivity < Activity
  def self.from(audit, appointment)
    return if only_the_guider_has_been_changed?(audit)

    create!(
      user_id: audit.user_id,
      owner_id: appointment.guider.id,
      message: message_for(audit),
      appointment_id: appointment.id
    )
  end

  def self.only_the_guider_has_been_changed?(audit)
    audit.audited_changes.keys == ['guider_id']
  end

  def self.message_for(audit)
    if audit.auditable_type == Appointment.model_name
      audit.audited_changes.keys.map(&:humanize).sort.to_sentence.downcase
    else
      'extra profile information'
    end
  end
end
