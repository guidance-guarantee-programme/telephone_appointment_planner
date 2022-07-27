class PrintedConfirmationJob < NotifyJobBase
  TEMPLATE_ID = '0d35b423-5e0f-456b-a36b-699f951a3be3'.freeze
  RESCHEDULE_TEMPLATE_ID = '343292a1-2158-450b-8e82-b9097150e5b2'.freeze

  def perform(appointment)
    return unless api_key(appointment.schedule_type) && appointment.print_confirmation?

    personalisation = PrintedConfirmationPresenter.new(appointment).to_h

    client = Notifications::Client.new(api_key(appointment.schedule_type))

    client.send_letter(
      template_id: template_id(appointment),
      reference: appointment.to_param,
      personalisation: personalisation
    )

    PrintedConfirmationActivity.from(appointment)
  end

  private

  def template_id(appointment)
    appointment.rescheduled_at? ? RESCHEDULE_TEMPLATE_ID : TEMPLATE_ID
  end
end
