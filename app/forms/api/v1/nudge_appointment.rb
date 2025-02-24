module Api
  module V1
    class NudgeAppointment
      include ActiveModel::Model

      attr_accessor :start_at, :first_name, :last_name, :email, :phone, :mobile, :memorable_word, :date_of_birth,
                    :accessibility_requirements, :notes, :agent, :nudge_confirmation, :nudge_eligibility_reason,
                    :gdpr_consent, :adjustments

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
          start_at:,
          first_name:,
          last_name:,
          email: email.to_s,
          phone:,
          mobile: mobile.to_s,
          date_of_birth:,
          memorable_word:,
          dc_pot_confirmed: true,
          where_you_heard: '2', # A Pension Provider
          accessibility_requirements:,
          notes:,
          adjustments: adjustments.to_s,
          agent:,
          smarter_signposted: false,
          lloyds_signposted: false,
          schedule_type: 'pension_wise',
          nudged: true,
          nudge_confirmation:,
          nudge_eligibility_reason:,
          gdpr_consent:
        }
      end
    end
  end
end
