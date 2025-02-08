class SmsAppointmentConfirmationJob < NotifyJobBase
  NUDGED_TEMPLATE_ID = '80c63000-d043-425e-b9cb-6a824bb66f56'.freeze
  DUE_DILIGENCE_TEMPLATE_ID = '58ef6845-25eb-4197-9cff-26457515d831'.freeze
  PENSION_WISE_TEMPLATE_ID = 'd9136496-a2f1-4262-86a6-d651c07dca87'.freeze

  include SmsFailureRecordable

  def perform(appointment)
    return unless api_key(appointment.schedule_type)

    send_sms_confirmation(appointment)
    create_activity(appointment)
  end

  private

  def send_sms_confirmation(appointment)
    client = Notifications::Client.new(api_key(appointment.schedule_type))

    client.send_sms(
      phone_number: appointment.canonical_sms_number,
      template_id: template_for(appointment),
      reference: appointment.to_param,
      personalisation: {
        date: "#{appointment.start_at.to_s(:govuk_date_short)} (#{appointment.timezone})",
        reference: appointment.to_param
      }
    )
  end

  def create_activity(appointment)
    SmsConfirmationActivity.create!(appointment:, owner: appointment.guider)
  end

  def template_for(appointment)
    if appointment.nudged?
      NUDGED_TEMPLATE_ID
    elsif appointment.due_diligence?
      DUE_DILIGENCE_TEMPLATE_ID
    else
      PENSION_WISE_TEMPLATE_ID
    end
  end
end
