module Genesys
  module Presenters
    class Appointment
      attr_reader :appointment

      def initialize(appointment, rescheduling:)
        @appointment = appointment
        @rescheduling = rescheduling
      end

      def start_at
        return appointment.start_at unless rescheduling?

        last_audited_changes['start_at'].first
      end

      def guider
        return appointment.guider unless rescheduling?

        if (guider_ids = last_audited_changes['guider_id'])
          User.find(guider_ids.first)
        else
          appointment.guider
        end
      end

      def genesys_activity_code_id
        return '0' if rescheduling?

        appointment.genesys_activity_code_id
      end

      delegate :id, to: :appointment

      private

      def rescheduling?
        @rescheduling
      end

      def last_audited_changes
        appointment.audits.last.audited_changes
      end
    end
  end
end
