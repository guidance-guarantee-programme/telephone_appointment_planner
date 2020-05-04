class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  before_action :authenticate_user!

  protect_from_forgery with: :exception

  add_flash_types :success, :warning

  def self.store_previous_page_on(actions)
    before_action only: actions do |controller|
      session[:previous_controller] = controller.controller_name
      session[:previous_action]     = controller.action_name
    end
  end

  protected

  def append_info_to_payload(payload)
    super

    payload[:params]    = request.filtered_parameters
    payload[:remote_ip] = request.remote_ip
    payload[:user_id]   = current_user&.id
  end

  def authorise_for_guiders!
    authorise_user!(User::GUIDER_PERMISSION)
  end

  def authorise_for_resource_managers!
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end

  def authorise_for_administrators!
    authorise_user!(User::ADMINISTRATOR_PERMISSION)
  end

  def authorise_for_api_users!
    authorise_user!(User::PENSION_WISE_API_PERMISSION)
  end

  def authorise_for_administrators_or_business_analysts!
    authorise_user!(
      any_of: [User::ADMINISTRATOR_PERMISSION, User::BUSINESS_ANALYST_PERMISSION]
    )
  end
end
