class AssignmentActivity < Activity
  ASSIGNED = 'assigned'.freeze
  REASSIGNED = 'reassigned'.freeze

  def allocated?
    message == ASSIGNED
  end

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
      message: ASSIGNED,
      appointment: appointment,
      owner: appointment.guider
    )
  end

  def self.create_reassignment(audit, appointment)
    prior_owner = User.find(audit.audited_changes['guider_id'].first)
    create!(
      user_id: audit.user_id,
      message: REASSIGNED,
      appointment: appointment,
      owner: appointment.guider,
      prior_owner_id: prior_owner.id
    )
  end
end
