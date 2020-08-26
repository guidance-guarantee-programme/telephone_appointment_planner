module Casebook
  module Presenters
    class Cancel
      OFFICE_CANCELLED = 'office_cancelled'.freeze
      CLIENT_CANCELLED = 'customer_cancelled'.freeze

      def initialize(appointment)
        @appointment = appointment
      end

      def to_h
        {
          data: {
            attributes: {
              cancel_status: cancel_status
            }
          }
        }
      end

      private

      def cancel_status
        case appointment.status
        when 'cancelled_by_customer', 'cancelled_by_customer_sms'
          CLIENT_CANCELLED
        else
          OFFICE_CANCELLED
        end
      end

      attr_reader :appointment
    end
  end
end
