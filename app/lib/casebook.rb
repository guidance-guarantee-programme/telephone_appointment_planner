module Casebook
  class ApiError < StandardError
    attr_reader :error

    def initialize(message = '', error = nil)
      super(message)

      @error = error
    end
  end
end
