require 'oauth2'

module Casebook
  class Api
    def initialize(client: nil)
      @client = client
    end

    def create(appointment)
      payload = Presenters::Create.new(appointment).to_h

      response = token.post('/api/v1/appointments', params: payload)
      Response.new(response.parsed)
    rescue OAuth2::Error => e
      raise ApiError.new(e.response.status, e)
    end

    def cancel(appointment)
      payload = Presenters::Cancel.new(appointment).to_h

      token.delete("/api/v1/appointments/#{appointment.casebook_appointment_id}", params: payload)
    rescue OAuth2::Error => e
      raise ApiError.new(e.response.status, e)
    end

    def reschedule(appointment)
      payload = Presenters::Reschedule.new(appointment).to_h

      response = token.post("/api/v1/appointments/#{appointment.casebook_appointment_id}/reschedule", params: payload)
      Response.new(response.parsed)
    rescue OAuth2::Error => e
      raise ApiError.new(e.response.status, e)
    end

    private

    def token
      @token ||= client.client_credentials.get_token(
        scope: 'appointments:create appointments:destroy appointments:reschedule'
      )
    end

    def client
      @client ||= OAuth2::Client.new(client_id, client_secret, site:, token_url:)
    end

    def site
      ENV['CASEBOOK_SITE']
    end

    def client_id
      ENV['CASEBOOK_CLIENT_ID']
    end

    def client_secret
      ENV['CASEBOOK_CLIENT_SECRET']
    end

    def token_url
      ENV['CASEBOOK_TOKEN_URL']
    end
  end
end
