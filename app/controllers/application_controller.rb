class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  before_action :require_signin_permission!

  protect_from_forgery with: :exception

  add_flash_types :success

  protected

  def authorise_for_guiders!
    authorise_user!(User::GUIDER_PERMISSION)
  end

  def authorise_for_resource_managers!
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end
end
