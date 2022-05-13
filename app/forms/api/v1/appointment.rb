module Api
  module V1
    class Appointment
      include ActiveModel::Model

      attr_accessor :start_at
      attr_accessor :first_name
      attr_accessor :last_name
      attr_accessor :email
      attr_accessor :phone
      attr_accessor :memorable_word
      attr_accessor :date_of_birth
      attr_accessor :dc_pot_confirmed
      attr_accessor :where_you_heard
      attr_accessor :gdpr_consent
      attr_accessor :accessibility_requirements
      attr_accessor :notes
      attr_accessor :agent
      attr_accessor :smarter_signposted
      attr_accessor :lloyds_signposted
      attr_accessor :schedule_type
      attr_accessor :referrer

      attr_reader :model

      attr_writer :nudged

      def initialize(*)
        super

        @model = ::Appointment.new(to_params)
      end

      def create
        model.allocate
        model.save
      end

      def nudged
        @nudged == 'true' || @nudged == true
      end

      delegate :errors, :accessibility_requirements?, to: :model

      private

      def to_params # rubocop:disable MethodLength, AbcSize
        {
          start_at: start_at,
          first_name: first_name,
          last_name: last_name,
          email: email,
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
