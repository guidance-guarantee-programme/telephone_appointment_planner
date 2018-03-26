class PrintBatchActivity < Activity
  def self.from(appointment)
    create!(appointment_id: appointment.id, owner_id: appointment.guider_id)
  end

  def pusher_notify_user_ids
    owner_id
  end
end
