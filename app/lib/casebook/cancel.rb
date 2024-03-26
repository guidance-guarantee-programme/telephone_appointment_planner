module Casebook
  class Cancel
    def initialize(appointment, api: Api.new)
      @appointment = appointment
      @api = api
    end

    def call
      api.cancel(appointment)

      appointment.process_casebook_cancellation!
    end

    private

    attr_reader :appointment, :api
  end
end
