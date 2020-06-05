class SmsCancellationFailureJob < NotifyJobBase
  TEMPLATE_ID = '41441952-e088-4ce6-beaf-61ee0435d68b'.freeze

  def perform(number)
    return unless api_key

    client.send_sms(
      phone_number: number,
      template_id: TEMPLATE_ID,
      reference: number
    )
  end
end
