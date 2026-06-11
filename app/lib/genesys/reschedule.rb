module Genesys
  class Reschedule
    def initialize(appointment, api: Api.new)
      @appointment = appointment
      @api = api
    end

    def call
      genesys_operation_id = api.push(appointment, rescheduling: true)

      appointment.process_genesys_rescheduling!(genesys_operation_id)
    end

    private

    attr_reader :appointment, :api
  end
end
