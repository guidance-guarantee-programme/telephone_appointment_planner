class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  before_action :require_signin_permission!

  protect_from_forgery with: :exception

  add_flash_types :success
end
