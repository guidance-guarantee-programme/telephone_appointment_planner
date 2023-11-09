class CustomerUpdateActivity < Activity
  CANCELLED_MESSAGE = 'cancelled'.freeze
  CONFIRMED_MESSAGE = 'confirmed'.freeze
  MISSED_MESSAGE = 'missed'.freeze
  UPDATED_MESSAGE = 'updated'.freeze

  def self.from(appointment, message)
    create!(
      appointment:,
      owner: appointment.guider,
      message:
    )
  end
end
