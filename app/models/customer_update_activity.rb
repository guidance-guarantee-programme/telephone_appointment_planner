class CustomerUpdateActivity < Activity
  CANCELLED_MESSAGE = 'cancelled'.freeze
  CONFIRMED_MESSAGE = 'confirmed'.freeze
  MISSED_MESSAGE = 'missed'.freeze
  UPDATED_MESSAGE = 'update'.freeze

  def self.from(appointment, message)
    create!(
      appointment: appointment,
      owner: appointment.guider,
      message: message
    )
  end
end
