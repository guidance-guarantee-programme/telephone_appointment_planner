module Genesys
  class AgentSchedule
    def initialize(response)
      @response = response
    end

    def agent_schedule
      result['agentSchedules'].first
    end

    def version
      agent_schedule['metadata']['version']
    end

    def result
      @response.parsed['result']
    end
  end
end
