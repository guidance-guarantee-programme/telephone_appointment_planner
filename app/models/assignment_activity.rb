class AssignmentActivity < Activity
  def self.from(audit, appointment)
    if audit.action == 'create'
      create_assignment(audit, appointment)
    elsif audit.audited_changes['guider_id'].present?
      create_reassignment(audit, appointment)
    end
  end

  def self.create_assignment(audit, appointment)
    create!(
      user_id: audit.user_id,
      message: 'assigned',
      appointment: appointment,
      owner: appointment.guider
    )
  end

  def self.create_reassignment(audit, appointment)
    create!(
      user_id: audit.user_id,
      message: 'reassigned',
      appointment: appointment,
      owner: appointment.guider,
      prior_owner_id: audit.audited_changes['guider_id'].first
    )
  end
end
