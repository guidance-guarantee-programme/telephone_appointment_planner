module Qualtrics
  class Api
    def appointment_booked(json_payload)
      connection.post(
        'triggers?urlTokenId=a3944b38-d0a7-4906-ae4c-fdfa4ecbf77e',
        json_payload
      )
    end

    private

    def connection
      @connection ||= Faraday.new(connection_options) do |faraday|
        faraday.request  :json
        faraday.response :raise_error
        faraday.use      :instrumentation
        faraday.adapter  :http
      end
    end

    def connection_options
      {
        url: ENV.fetch('QUALTRICS_URI'),
        headers: {
          'X-API-TOKEN' => ENV.fetch('QUALTRICS_API_TOKEN')
        }
      }
    end
  end
end
