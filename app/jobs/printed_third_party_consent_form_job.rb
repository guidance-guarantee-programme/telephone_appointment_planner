class PrintedThirdPartyConsentFormJob < NotifyJobBase
  TEMPLATE_ID = 'affc3f1f-3e36-480a-92df-bfb3a17bc4af'.freeze

  def perform(appointment)
    return unless api_key(appointment.schedule_type) && appointment.printed_consent_form_required?

    personalisation = PrintedThirdPartyConsentFormPresenter.new(appointment).to_h

    client = Notifications::Client.new(api_key(appointment.schedule_type))

    client.send_letter(
      template_id: TEMPLATE_ID,
      reference: appointment.to_param,
      personalisation: personalisation
    )

    PrintedThirdPartyConsentFormActivity.from(appointment)
  end
end
