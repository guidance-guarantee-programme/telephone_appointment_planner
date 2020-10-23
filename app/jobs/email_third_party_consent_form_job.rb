class EmailThirdPartyConsentFormJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    return unless appointment.email_consent_form_required? && appointment.email_consent?

    render_and_attach_pdf(appointment)

    AppointmentMailer.consent_form(appointment).deliver_now

    EmailThirdPartyConsentFormActivity.from(appointment)
  end

  private

  def render_and_attach_pdf(appointment)
    pdf = PdfRenderer.new(appointment).call

    appointment.generated_consent_form.attach(
      io: pdf,
      filename: "#{appointment.id}.pdf",
      content_type: 'application/pdf'
    )
  end
end
