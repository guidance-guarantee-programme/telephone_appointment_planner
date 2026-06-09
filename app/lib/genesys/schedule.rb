module Genesys
  class Schedule
    def initialize(response)
      @response = response
    end

    def published_schedule_uri
      Rails.logger.info('Genesys Published Schedules')
      Rails.logger.info(response.parsed['result']['publishedSchedules'])

      response.parsed['result']['publishedSchedules'].first['selfUri']
    end

    private

    attr_reader :response
  end
end
