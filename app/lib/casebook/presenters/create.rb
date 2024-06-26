module Casebook
  module Presenters
    class Create
      def initialize(appointment)
        @appointment = appointment
      end

      def to_h # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        {
          data: {
            attributes: {
              first_name: appointment.first_name,
              last_name: appointment.last_name,
              date_of_birth: appointment.date_of_birth.to_s,
              mobile_phone: appointment.canonical_sms_number.gsub(/\D/, ''),
              email: appointment.email,
              starts_at: starts_at.iso8601,
              ends_at: ends_at.iso8601,
              notes:,
              user_id: appointment.guider.casebook_guider_id,
              channel: 'telephone',
              location_id: appointment.guider.casebook_location_id
            }
          }
        }
      end

      private

      def notes
        "Pension Wise online booking ##{appointment.id}.#{duplicates}"
      end

      def duplicates
        return '' unless appointment.potential_duplicates?

        " Possible duplicate appointments: #{appointment.potential_duplicates.pluck(:id).to_sentence} [TAP]"
      end

      def starts_at
        return appointment.start_at if gmt?

        appointment.start_at.advance(hours: -1)
      end

      def ends_at
        return appointment.end_at if gmt?

        appointment.end_at.advance(hours: -1)
      end

      def gmt?
        appointment.start_at.in_time_zone('London').utc_offset.zero?
      end

      attr_reader :appointment
    end
  end
end
