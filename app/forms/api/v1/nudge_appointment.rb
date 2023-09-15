module Api
  module V1
    class NudgeAppointment
      include ActiveModel::Model

      attr_accessor :start_at
      attr_accessor :first_name
      attr_accessor :last_name
      attr_accessor :email
      attr_accessor :phone
      attr_accessor :mobile
      attr_accessor :memorable_word
      attr_accessor :date_of_birth
      attr_accessor :accessibility_requirements
      attr_accessor :notes
      attr_accessor :agent
      attr_accessor :nudge_confirmation
      attr_accessor :nudge_eligibility_reason
      attr_accessor :gdpr_consent

      attr_reader :model

      def initialize(*)
        super

        @model = ::Appointment.new(to_params)
      end

      def create
        model.allocate
        model.save
      end

      delegate :errors, :accessibility_requirements?, to: :model

      private

      def to_params # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        {
          start_at: start_at,
          first_name: first_name,
          last_name: last_name,
          email: email.to_s,
          phone: phone,
          mobile: mobile.to_s,
          date_of_birth: date_of_birth,
          memorable_word: memorable_word,
          dc_pot_confirmed: true,
          where_you_heard: '2', # A Pension Provider
          accessibility_requirements: accessibility_requirements,
          notes: notes,
          agent: agent,
          smarter_signposted: false,
          lloyds_signposted: false,
          schedule_type: 'pension_wise',
          nudged: true,
          nudge_confirmation: nudge_confirmation,
          nudge_eligibility_reason: nudge_eligibility_reason,
          gdpr_consent: gdpr_consent
        }
      end
    end
  end
end
