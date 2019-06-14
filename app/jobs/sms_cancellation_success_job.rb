class SmsCancellationSuccessJob < SmsJobBase
  TEMPLATE_ID = 'fd90b779-03e1-471d-b9e4-34afa9622410'.freeze

  def perform(appointment)
    return unless api_key

    sms_client.send_sms(
      phone_number: appointment.canonical_sms_number,
      template_id: TEMPLATE_ID,
      reference: appointment.to_param,
      personalisation: {
        date: "#{appointment.start_at.to_s(:govuk_date_short)} (#{appointment.timezone})"
      }
    )
  end
end
