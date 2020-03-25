module Api
  module V1
    class AppointmentsController < Api::V1::ApplicationController
      def create
        @appointment = Api::V1::Appointment.new(appointment_params)

        if @appointment.create
          send_notifications(@appointment.model)
          head :created, location: @appointment.model
        else
          render json: @appointment.errors, status: :unprocessable_entity
        end
      end

      private

      def send_notifications(appointment)
        AccessibilityAdjustmentNotificationsJob.perform_later(appointment) if appointment.accessibility_requirements?
        WebsiteAppointmentSlackPingerJob.perform_later
        CustomerUpdateJob.perform_later(appointment, CustomerUpdateActivity::CONFIRMED_MESSAGE)
        AppointmentCreatedNotificationsJob.perform_later(appointment)
      end

      def appointment_params # rubocop:disable Metrics/MethodLength
        params.permit(
          :start_at,
          :first_name,
          :last_name,
          :email,
          :phone,
          :memorable_word,
          :date_of_birth,
          :dc_pot_confirmed,
          :where_you_heard,
          :gdpr_consent,
          :accessibility_requirements,
          :notes
        ).merge(agent: current_user)
      end
    end
  end
end
