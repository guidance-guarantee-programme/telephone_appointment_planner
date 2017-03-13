class CustomerUpdateActivity < Activity
  def self.from(appointment)
    create!(
      appointment: appointment,
      owner: appointment.guider,
      message: 'updated'
    )
  end
end
