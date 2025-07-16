class CustomerOnlineReschedulingActivity < Activity
  def self.from(appointment)
    create!(
      appointment:,
      owner: appointment.guider
    )
  end
end
