require 'faraday'
require 'faraday/conductivity'

class SummaryDocumentApi
  def reissue_digital_summary(reference, email, current_user)
    connection.put(
      "/api/v1/appointment_summaries/#{reference}",
      { email: email, initiator_uid: current_user.uid }.to_json,
      'Content-Type' => 'application/json'
    )

    true
  rescue Faraday::ClientError
    false
  end

  def digital_summary_email(reference)
    response = connection.get("/api/v1/appointment_summaries/#{reference}")
    response.body['email']
  rescue Faraday::ResourceNotFound
    nil
  end

  private

  def connection
    Faraday.new(connection_options) do |faraday|
      faraday.request :json
      faraday.response :raise_error
      faraday.response :json
      faraday.use :instrumentation
      faraday.adapter :http
      faraday.authorization :Bearer, bearer_token if bearer_token
      faraday.headers[:accept] = 'application/json'
    end
  end

  def connection_options
    {
      url: api_uri,
      request: {
        timeout: read_timeout,
        open_timeout: open_timeout
      }
    }
  end

  def open_timeout
    ENV.fetch('SUMMARY_DOCUMENT_API_OPEN_TIMEOUT', 2).to_i
  end

  def read_timeout
    ENV.fetch('SUMMARY_DOCUMENT_API_READ_TIMEOUT', 2).to_i
  end

  def api_uri
    ENV.fetch('SUMMARY_DOCUMENT_API_URI') { 'http://localhost:3010' }
  end

  def bearer_token
    ENV['SUMMARY_DOCUMENT_API_BEARER_TOKEN']
  end
end
