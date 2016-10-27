class AuditActivity < Activity
  def self.from(audit, appointment)
    create!(
      user_id: audit.user_id,
      message: audit.audited_changes.keys.map(&:humanize).to_sentence.downcase,
      appointment_id: appointment.id
    )
  end
end
