class NudgeSmsAppointmentConfirmationJob < NotifyJobBase
  TEMPLATE_ID = '80c63000-d043-425e-b9cb-6a824bb66f56'.freeze

  def perform(appointment)
    return unless api_key(appointment.schedule_type)

    send_sms_confirmation(appointment)
    create_activity(appointment)
  end

  private

  def send_sms_confirmation(appointment)
    client = Notifications::Client.new(api_key(appointment.schedule_type))

    client.send_sms(
      phone_number: appointment.mobile,
      template_id: TEMPLATE_ID,
      reference: appointment.to_param,
      personalisation: {
        date: "#{appointment.start_at.to_s(:govuk_date_short)} (#{appointment.timezone})",
        reference: appointment.to_param
      }
    )
  end

  def create_activity(appointment)
    NudgeSmsConfirmationActivity.create!(appointment:, owner: appointment.guider)
  end
end
