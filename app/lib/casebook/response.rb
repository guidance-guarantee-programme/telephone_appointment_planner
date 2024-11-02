module Casebook
  class Response
    def initialize(response)
      @response = response
    end

    def appointment_id
      @response['data']['id']
    end

    def case_reference_number
      @response['data']['attributes']['case-reference-number']
    end
  end
end
