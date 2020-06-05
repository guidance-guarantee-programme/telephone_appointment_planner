module Casebook
  class Push
    def initialize(appointment, api: Api.new)
      @appointment = appointment
      @api = api
    end

    def call
      casebook_identifier = api.create(appointment)

      appointment.process_casebook!(casebook_identifier)
    end

    private

    attr_reader :appointment
    attr_reader :api
  end
end
