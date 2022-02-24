module Casebook
  class Reschedule
    def initialize(appointment, api: Api.new)
      @appointment = appointment
      @api = api
    end

    def call
      casebook_identifier = api.reschedule(appointment)

      appointment.process_casebook!(casebook_identifier)
    end

    private

    attr_reader :appointment, :api
  end
end
