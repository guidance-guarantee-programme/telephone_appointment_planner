class ProcessedActivity < Activity
  def self.from(user:, appointment:)
    create!(
      appointment:,
      user:,
      owner: appointment.guider
    )
  end
end
