module Api
  module V1
    class BookableSlotsController < ActionController::Base
      include GDS::SSO::ControllerMethods

      before_action { authorise_user!(User::PENSION_WISE_API_PERMISSION) }

      def index
        render json: BookableSlot.grouped
      end
    end
  end
end
