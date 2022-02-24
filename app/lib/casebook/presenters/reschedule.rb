module Casebook
  module Presenters
    class Reschedule < Create
      def to_h
        super.tap do |h|
          h[:data][:attributes][:reschedule_status] = appointment.rescheduling_reason
        end
      end
    end
  end
end
