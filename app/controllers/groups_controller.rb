class GroupsController < ApplicationController
  before_action :authorise_for_resource_managers!

  def index
    @guiders = current_user.colleagues.find(user_ids)
    @groups  = Group.assigned_to(user_ids)
    @all_groups = Group.for_user(current_user).pluck(:name)
  end

  def create
    CreateGroupAssignments.new(
      user_ids,
      group_params[:name].select(&:present?),
      current_user
    ).call

    go_back_with_success('assigned to')
  end

  def destroy
    DestroyGroupAssignments.new(user_ids, params[:id]).call
    go_back_with_success('unassigned from')
  end

  private

  def go_back_with_success(action)
    redirect_back(
      fallback_location: users_path,
      success: "The users were #{action} the specified groups"
    )
  end

  def group_params
    params.require(:group).permit(name: [])
  end

  def user_ids
    params[:user_ids].split(',')
  end
end
