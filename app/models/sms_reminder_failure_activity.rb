class SmsReminderFailureActivity < Activity
  def self.from(appointment)
    create!(
      owner: appointment.guider,
      appointment:,
      message: "could not deliver an SMS reminder to '#{appointment.canonical_sms_number}'. " \
        'The number is incorrect or invalid.'
    )
  end
end
