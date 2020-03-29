class ProcessedActivity < Activity
  def self.from(user:, appointment:)
    create!(
      appointment: appointment,
      user: user,
      owner: appointment.guider
    )
  end
end
