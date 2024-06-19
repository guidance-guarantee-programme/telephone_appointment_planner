module Api
  module V1
    class AppointmentCancellation
      include ActiveModel::Model

      attr_accessor :appointment_id, :date_of_birth

      def cancel
        return false unless appointment

        appointment.self_serve_cancel!
      end

      def model
        appointment
      end

      private

      def appointment
        @appointment ||= ::Appointment.find_by(id: appointment_id, date_of_birth:, status: :pending)
      end
    end
  end
end
