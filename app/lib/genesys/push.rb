module Genesys
  class Push
    def initialize(appointment, api: Api.new)
      @appointment = appointment
      @api = api
    end

    def call
      genesys_operation_id = api.push(appointment)

      appointment.process_genesys_creation!(genesys_operation_id)
    end

    private

    attr_reader :appointment, :api
  end
end
