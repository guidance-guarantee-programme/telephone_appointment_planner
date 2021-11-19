class SmsCancellationFailureJob < NotifyJobBase
  TEMPLATES = {
    'pension_wise'  => '41441952-e088-4ce6-beaf-61ee0435d68b',
    'due_diligence' => 'cdd0fb8c-fb90-4bae-b3de-7eee939d5b0e'
  }.freeze

  def perform(number, schedule_type)
    return unless api_key(schedule_type)

    client = Notifications::Client.new(api_key(schedule_type))

    client.send_sms(
      phone_number: number,
      template_id: TEMPLATES.fetch(schedule_type),
      reference: number
    )
  end
end
