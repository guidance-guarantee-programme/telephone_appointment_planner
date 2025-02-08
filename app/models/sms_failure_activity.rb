class SmsFailureActivity < Activity
  def self.from(appointment)
    create!(
      owner: appointment.guider,
      appointment:,
      message: "could not deliver an SMS to '#{appointment.canonical_sms_number}'. " \
        'The number is incorrect or invalid.'
    )
  end
end
