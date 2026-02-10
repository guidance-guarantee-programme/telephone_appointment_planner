module Genesys
  class Upload
    def initialize(response)
      @response = response
    end

    def upload_key
      parsed_response['uploadKey']
    end

    def url
      parsed_response['url']
    end

    def headers
      parsed_response['headers']
    end

    def parsed_response
      @parsed_response ||= @response.parsed
    end
  end
end
