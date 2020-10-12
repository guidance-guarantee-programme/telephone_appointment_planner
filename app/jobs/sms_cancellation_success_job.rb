class SmsCancellationSuccessJob < SmsJobBase
  STANDARD_TEMPLATE_ID = 'fd90b779-03e1-471d-b9e4-34afa9622410'.freeze
  BSL_TEMPLATE_ID      = '43fb57ed-1abe-4115-81ca-10f5042e23ca'.freeze

  def perform(appointment)
    return unless api_key

    sms_client.send_sms(
      phone_number: appointment.canonical_sms_number,
      template_id: template_for(appointment),
      reference: appointment.to_param,
      personalisation: {
        date: "#{appointment.start_at.to_s(:govuk_date_short)} (#{appointment.timezone})"
      }
    )
  end

  private

  def template_for(appointment)
    if appointment.bsl_video?
      BSL_TEMPLATE_ID
    else
      STANDARD_TEMPLATE_ID
    end
  end
end
