module Casebook
  module Presenters
    class Reschedule < Create
      def to_h
        super.tap do |h|
          h[:data][:attributes][:reschedule_status] = rescheduling_reason
        end
      end

      private

      def rescheduling_reason
        appointment.rescheduling_reason.presence || Appointment::OFFICE_RESCHEDULED
      end
    end
  end
end
