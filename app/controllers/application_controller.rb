class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  before_action :require_signin_permission!

  protect_from_forgery with: :exception

  add_flash_types :success

  protected

  def poll_interval_milliseconds
    Integer(ENV.fetch(Activity::POLLING_KEY, 5000))
  end
  helper_method :poll_interval_milliseconds
end
