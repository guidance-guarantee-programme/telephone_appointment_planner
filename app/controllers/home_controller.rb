class HomeController < ApplicationController
  def index
    return redirect_to allocations_path, status: :moved_permanently if current_user.resource_manager?
    return redirect_to new_appointment_path, status: :moved_permanently if current_user.agent?
    return redirect_to my_appointments_path, status: :moved_permanently if current_user.guider?
  end
end
