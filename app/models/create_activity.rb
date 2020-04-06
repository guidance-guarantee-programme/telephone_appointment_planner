class CreateActivity < Activity
  def self.from(audit, appointment)
    create!(
      user_id: audit.user_id,
      appointment_id: appointment.id,
      owner_id: appointment.guider.id
    )
  end
end
