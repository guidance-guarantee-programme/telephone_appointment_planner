module Genesys
  module Presenters
    class Appointment
      attr_reader :appointment

      def initialize(appointment, rescheduling:)
        @appointment = appointment
        @rescheduling = rescheduling
      end

      def start_at
        return start_at_in_time_zone(appointment.start_at) unless rescheduling?

        start_at_in_time_zone(last_audited_changes['start_at'].first)
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

      def start_at_in_time_zone(start_at)
        return start_at if gmt?(start_at)

        start_at.advance(hours: -1)
      end

      def gmt?(start_at)
        start_at.in_time_zone('London').utc_offset.zero?
      end

      def rescheduling?
        @rescheduling
      end

      def last_audited_changes
        appointment.audits.last.audited_changes
      end
    end
  end
end
