module Api
  module V1
    class AppointmentsController < Api::V1::ApplicationController
      class InvalidScheduleType < StandardError; end

      rescue_from InvalidScheduleType do
        head :unprocessable_entity
      end

      def create
        @appointment = Api::V1::Appointment.new(appointment_params)

        if @appointment.create
          send_notifications(@appointment.model)
          head :created, location: @appointment.model
        else
          render json: @appointment.errors, status: :unprocessable_entity
        end
      end

      def show
        @appointment = ::Appointment.for_online_rescheduling(*show_params.values)

        return head :not_found unless @appointment

        render json: @appointment
      end

      private

      def send_notifications(appointment)
        SmsAppointmentConfirmationJob.perform_later(appointment) if appointment.mobile?
        AdjustmentNotificationsJob.perform_later(appointment) if appointment.adjustments?
        AppointmentMailer.potential_duplicates(appointment).deliver_later if appointment.potential_duplicates?
        CustomerUpdateJob.perform_later(appointment, CustomerUpdateActivity::CONFIRMED_MESSAGE)
        AppointmentCreatedNotificationsJob.perform_later(appointment)
        PushCasebookAppointmentJob.perform_later(appointment)
      end

      def show_params
        params.permit(:id, :date_of_birth)
      end

      def appointment_params # rubocop:disable Metrics/MethodLength
        params.permit(
          :start_at,
          :first_name,
          :last_name,
          :email,
          :country_code,
          :phone,
          :memorable_word,
          :date_of_birth,
          :dc_pot_confirmed,
          :where_you_heard,
          :gdpr_consent,
          :accessibility_requirements,
          :notes,
          :smarter_signposted,
          :lloyds_signposted,
          :referrer,
          :nudged,
          :rebooked_from_id,
          :attended_digital,
          :adjustments
        ).merge(
          agent: current_user,
          schedule_type:
        )
      end

      def schedule_type
        # TODO: Pull this up and the same in the slots API
        @schedule_type = params.fetch(:schedule_type) { User::PENSION_WISE_SCHEDULE_TYPE }

        return @schedule_type if User::ALL_SCHEDULE_TYPES.include?(@schedule_type)

        raise InvalidScheduleType
      end
    end
  end
end
