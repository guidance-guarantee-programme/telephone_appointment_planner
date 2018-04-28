class SmsCancellationActivity < Activity
  def self.from(appointment)
    create!(
      appointment: appointment,
      owner: appointment.guider
    )
  end
end
