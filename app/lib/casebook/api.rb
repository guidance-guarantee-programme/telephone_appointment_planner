require 'oauth2'

module Casebook
  class Api
    def create(appointment)
      payload = Presenters::Create.new(appointment).to_h

      response = token.post('/api/v1/appointments', params: payload)
      response.parsed['data']['id']
    rescue OAuth2::Error => e
      raise ApiError, e.description
    end

    private

    def token
      @token ||= client.client_credentials.get_token(scope: 'appointments:create')
    end

    def client
      @client ||= OAuth2::Client.new(client_id, client_secret, site: site, token_url: token_url)
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
