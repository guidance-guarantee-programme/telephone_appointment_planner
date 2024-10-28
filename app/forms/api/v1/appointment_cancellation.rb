module Api
  module V1
    class AppointmentCancellation
      include ActiveModel::Model

      attr_accessor :appointment_id, :date_of_birth, :secondary_status, :other_reason

      def cancel
        return false unless appointment

        appointment.self_serve_cancel!(secondary_status, other_reason)
      end

      def model
        appointment
      end

      private

      def appointment
        @appointment ||= ::Appointment.where('? < start_at', Time.zone.now).find_by(
          id: appointment_id,
          date_of_birth:,
          status: :pending,
          schedule_type: User::PENSION_WISE_SCHEDULE_TYPE
        )
      end
    end
  end
end
