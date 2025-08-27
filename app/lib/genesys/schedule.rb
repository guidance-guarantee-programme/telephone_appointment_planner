module Genesys
  class Schedule
    def initialize(response)
      @response = response
    end

    def published_schedule_uri
      response.parsed['result']['publishedSchedules'].last['selfUri']
    end

    private

    attr_reader :response
  end
end
