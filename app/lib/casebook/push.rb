module Casebook
  class Push
    def initialize(appointment, api: Api.new)
      @appointment = appointment
      @api = api
    end

    def call
      casebook_response = api.create(appointment)

      appointment.process_casebook!(casebook_response)
    end

    private

    attr_reader :appointment, :api
  end
end
