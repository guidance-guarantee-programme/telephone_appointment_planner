module Genesys
  class FullSchedule
    def initialize(response)
      @response = response
    end

    def version
      @response.parsed['metadata']['version']
    end
  end
end
