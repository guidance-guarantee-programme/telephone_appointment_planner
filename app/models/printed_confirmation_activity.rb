class PrintedConfirmationActivity < Activity
  def self.from(appointment)
    create!(
      appointment_id: appointment.id,
      message: appointment.rescheduled_at? ? 'rescheduled' : 'confirmation'
    )
  end

  def owner_required?
    false
  end
end
