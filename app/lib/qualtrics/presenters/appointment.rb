module Qualtrics
  module Presenters
    class Appointment
      def initialize(appointment)
        @appointment = appointment
      end

      def to_h
        {
          reference: appointment.id,
          first_name: appointment.first_name,
          last_name: appointment.last_name,
          email: appointment.email,
          mobile:,
          type:
        }
      end

      private

      attr_reader :appointment

      def mobile
        return '' unless appointment.mobile?

        appointment.canonical_sms_number
      end

      def type
        appointment.pension_wise? ? 'pensionwise-phone' : 'psg-phone'
      end
    end
  end
end
