module Api
  module V1
    class Appointment
      include ActiveModel::Model

      attr_accessor :start_at, :first_name, :last_name, :email, :phone, :memorable_word, :date_of_birth,
                    :dc_pot_confirmed, :where_you_heard, :gdpr_consent, :accessibility_requirements,
                    :notes, :agent, :smarter_signposted, :lloyds_signposted, :schedule_type, :referrer

      attr_reader :model

      attr_writer :nudged, :country_code

      def initialize(*)
        super

        @model = ::Appointment.new(to_params)
      end

      def create
        model.allocate(agent: agent)
        model.save
      end

      def nudged
        @nudged == 'true' || @nudged == true
      end

      def country_code
        @country_code || ::Appointment::DEFAULT_COUNTRY_CODE
      end

      delegate :errors, :accessibility_requirements?, to: :model

      private

      def to_params # rubocop:disable Metrics/AbcSize
        {
          start_at: start_at,
          first_name: first_name,
          last_name: last_name,
          email: email,
          country_code: country_code,
          phone: phone,
          date_of_birth: date_of_birth,
          memorable_word: memorable_word,
          dc_pot_confirmed: dc_pot_confirmed,
          where_you_heard: where_you_heard,
          gdpr_consent: gdpr_consent.to_s,
          accessibility_requirements: accessibility_requirements,
          notes: notes,
          pension_provider: 'n/a',
          agent: agent,
          smarter_signposted: smarter_signposted,
          lloyds_signposted: lloyds_signposted || false,
          schedule_type: schedule_type,
          referrer: referrer.to_s,
          nudged: nudged
        }
      end
    end
  end
end
