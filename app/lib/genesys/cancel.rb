module Genesys
  class Cancel
    def initialize(appointment, api: Api.new)
      @appointment = appointment
      @api = api
    end

    def call
      api.push(appointment, rescheduling: true)

      appointment.process_genesys_creation!('')
    end

    private

    attr_reader :appointment, :api
  end
end
