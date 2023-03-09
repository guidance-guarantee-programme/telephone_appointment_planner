class PrintedConfirmationFailedActivity < Activity
  def self.from(appointment)
    create!(
      appointment_id: appointment.id,
      message: appointment.rescheduled_at? ? 'rescheduled' : 'confirmation',
      owner: appointment.agent
    )
  end
end
