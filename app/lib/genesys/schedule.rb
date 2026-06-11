module Genesys
  class Schedule
    def initialize(response, appointment)
      @response = response
      @appointment = appointment
    end

    def published_schedule_uri
      result = published_schedules.find { |schedule| schedule['weekDate'] == appointment.week_date }

      unless result
        Rails.logger.debug(published_schedules)
        raise "Could not find a published schedule for #{appointment.id} on #{appointment.week_date}"
      end

      result['selfUri']
    end

    private

    def published_schedules
      Array(response.parsed.dig('result', 'publishedSchedules'))
    end

    attr_reader :response, :appointment
  end
end
