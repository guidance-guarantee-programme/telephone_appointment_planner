module Api
  module V1
    class ApplicationController < ActionController::Base
      include GDS::SSO::ControllerMethods

      before_action { authorise_user!(User::PENSION_WISE_API_PERMISSION) }

      wrap_parameters false
    end
  end
end
