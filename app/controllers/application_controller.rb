class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  before_action :require_signin_permission!

  protect_from_forgery with: :exception

  add_flash_types :success

  def self.store_previous_page_on(actions)
    before_action only: actions do |controller|
      session[:previous_controller] = controller.controller_name
      session[:previous_action]     = controller.action_name
    end
  end

  protected

  def append_info_to_payload(payload)
    super
    payload[:params] = request.filtered_parameters
  end

  def authorise_for_guiders!
    authorise_user!(User::GUIDER_PERMISSION)
  end

  def authorise_for_resource_managers!
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end
end
