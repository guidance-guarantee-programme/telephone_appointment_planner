module Api
  module V1
    class ApplicationController < ActionController::Base
      include GDS::SSO::ControllerMethods

      before_action { authorise_user!(User::PENSION_WISE_API_PERMISSION) }

      wrap_parameters false

      skip_forgery_protection

      protected

      def append_info_to_payload(payload)
        super
        payload[:params] = request.filtered_parameters
      end
    end
  end
end
