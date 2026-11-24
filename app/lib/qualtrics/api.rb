module Qualtrics
  class Api
    def appointment_booked(json_payload)
      connection.post(
        'triggers?urlTokenId=a3944b38-d0a7-4906-ae4c-fdfa4ecbf77e',
        json_payload
      )
    end

    def appointment_completed(json_payload, pension_wise: true)
      connection.post(
        trigger_path(pension_wise:),
        json_payload
      )
    end

    private

    def trigger_path(pension_wise:)
      if pension_wise
        'triggers?urlTokenId=2f76f7a3-f44b-4083-91bf-2ed8860f05e8'
      else
        'triggers?urlTokenId=6465ca89-5f31-4cde-9589-12e2216c4f78'
      end
    end

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
