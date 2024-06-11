module Api
  module V1
    class NudgeAppointmentsController < Api::V1::ApplicationController
      def create
        @appointment = Api::V1::NudgeAppointment.new(appointment_params)

        if @appointment.create
          send_notifications(@appointment.model)
          head :created, location: @appointment.model
        else
          render json: @appointment.errors, status: :unprocessable_entity
        end
      end

      private

      def send_notifications(appointment)
        AdjustmentNotificationsJob.perform_later(appointment) if appointment.adjustments?
        AppointmentMailer.potential_duplicates(appointment).deliver_later if appointment.potential_duplicates?
        NudgeSmsAppointmentConfirmationJob.perform_later(appointment) if appointment.sms_confirmation?
        CustomerUpdateJob.perform_later(appointment, CustomerUpdateActivity::CONFIRMED_MESSAGE)
        AppointmentCreatedNotificationsJob.perform_later(appointment)
        PushCasebookAppointmentJob.perform_later(appointment)
      end

      def appointment_params # rubocop:disable Metrics/MethodLength
        params.permit(
          :start_at,
          :first_name,
          :last_name,
          :email,
          :phone,
          :mobile,
          :nudge_confirmation,
          :nudge_eligibility_reason,
          :memorable_word,
          :date_of_birth,
          :accessibility_requirements,
          :notes,
          :gdpr_consent
        ).merge(agent: current_user)
      end
    end
  end
end
