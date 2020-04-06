class PrintBatchActivity < Activity
  def self.from(appointment)
    create!(appointment_id: appointment.id, owner_id: appointment.guider_id)
  end
end
