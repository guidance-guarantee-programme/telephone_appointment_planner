require 'notifications/client'

class SmsCancellationFailureJob < ApplicationJob
  TEMPLATE_ID = '41441952-e088-4ce6-beaf-61ee0435d68b'.freeze

  queue_as :default

  rescue_from(Notifications::Client::RequestError) do |exception|
    Bugsnag.notify(exception)
  end

  def perform(number)
    return unless api_key

    sms_client.send_sms(
      phone_number: number,
      template_id: TEMPLATE_ID,
      reference: number
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
