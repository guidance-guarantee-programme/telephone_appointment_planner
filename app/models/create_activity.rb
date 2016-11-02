class CreateActivity < Activity
  def self.from(audit, appointment)
    create!(
      user_id: audit.user_id,
      message: 'created this appointment',
      appointment_id: appointment.id
    )
  end
end
