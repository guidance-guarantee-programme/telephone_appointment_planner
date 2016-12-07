class AssignmentActivity < Activity
  ASSIGNED = 'assigned'.freeze

  def message
    if allocated?(super)
      "#{owner.name} was allocated a new appointment"
    else
      "#{user_name} allocated this appointment to #{owner.name}"
    end
  end

  def allocated?(type)
    type == ASSIGNED
  end

  def self.from(audit, appointment)
    if audit.action == 'create'
      create_assignment(audit, appointment)
    elsif audit.audited_changes['guider_id'].present?
      create_reassignment(audit, appointment)
    end
  end

  def self.create_assignment(audit, appointment)
    activity = create!(
      user_id: audit.user_id,
      message: ASSIGNED,
      appointment: appointment,
      owner: appointment.guider
    )
    PusherActivityNotificationJob.perform_later(appointment.guider, activity)
  end

  def self.create_reassignment(audit, appointment)
    prior_owner = User.find(audit.audited_changes['guider_id'].first)
    activity = create!(
      user_id: audit.user_id,
      message: 'reassigned',
      appointment: appointment,
      owner: appointment.guider,
      prior_owner_id: prior_owner.id
    )
    PusherActivityNotificationJob.perform_later(appointment.guider, activity)
    PusherActivityNotificationJob.perform_later(prior_owner, activity)
  end
end
