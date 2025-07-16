module Api
  module V1
    class AppointmentRescheduling
      include ActiveModel::Model

      attr_accessor :reference, :date_of_birth, :reason, :start_at

      validates :appointment, presence: true
      validates :reference, presence: true
      validates :date_of_birth, presence: true
      validates :reason, presence: true
      validates :start_at, presence: true

      def reschedule
        return if invalid?

        appointment.online_reschedule(start_at:, reason:)
      end

      def model
        @appointment
      end

      private

      def appointment
        @appointment ||= ::Appointment.for_online_rescheduling(reference, date_of_birth)
      end
    end
  end
end
