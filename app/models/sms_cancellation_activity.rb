class SmsCancellationActivity < Activity
  def self.from(appointment)
    create!(
      appointment: appointment,
      owner: appointment.guider
    )
  end

  def pusher_notify_user_ids
    appointment.guider_id
  end
end
