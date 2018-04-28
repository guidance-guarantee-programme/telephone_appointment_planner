require 'notifications/client'

class SmsCancellationSuccessJob < ApplicationJob
  TEMPLATE_ID = 'fd90b779-03e1-471d-b9e4-34afa9622410'.freeze

  queue_as :default

  rescue_from(Notifications::Client::RequestError) do |exception|
    Bugsnag.notify(exception)
  end

  def perform(appointment)
    return unless api_key

    sms_client.send_sms(
      phone_number: appointment.canonical_sms_number,
      template_id: TEMPLATE_ID,
      reference: appointment.to_param
    )
  end

  private

  def sms_client
    @sms_client ||= Notifications::Client.new(api_key)
  end

  def api_key
    ENV['NOTIFY_API_KEY']
  end
end
