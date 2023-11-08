module MailgunHeaders
  def mailgun_headers(message_type, appointment_id)
    headers['X-Mailgun-Variables'] = headers_hash(message_type, appointment_id)
  end

  private

  def headers_hash(message_type, appointment_id)
    {
      message_type:,
      appointment_id:,
      environment: Rails.env
    }.to_json
  end
end
