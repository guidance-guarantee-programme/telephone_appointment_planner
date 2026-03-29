module Genesys
  module Presenters
    class Schedule
      def initialize(schedule_version, agent_schedule)
        @schedule_version = schedule_version
        @agent_schedule = agent_schedule
      end

      def to_h
        {
          'metadata' => { 'version' => @schedule_version.version },
          'agentSchedules' => [
            @agent_schedule.to_h
          ]
        }
      end
    end
  end
end
