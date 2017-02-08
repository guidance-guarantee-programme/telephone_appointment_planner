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
      attr_accessor :opt_out_of_market_research
      attr_accessor :agent

      attr_reader :model

      def initialize(*)
        super

        @model = Models::Appointment.new(to_params)
      end

      def create
        model.assign_to_guider
        model.save
      end

      delegate :errors, to: :model

      private

      def to_params # rubocop:disable Metrics/MethodLength
        {
          start_at: start_at,
          first_name: first_name,
          last_name: last_name,
          email: email,
          phone: phone,
          date_of_birth: date_of_birth,
          memorable_word: memorable_word,
          dc_pot_confirmed: dc_pot_confirmed,
          opt_out_of_market_research: opt_out_of_market_research,
          agent: agent
        }
      end
    end
  end
end