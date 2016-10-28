class GroupsController < ApplicationController
  before_action :authorise_for_resource_managers!

  def index
    @guiders = User.find(user_ids)
    @groups  = Group.assigned_to(user_ids)
  end

  def create
    CreateGroupAssignments.new(user_ids, group_params[:name]).call
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
    params.require(:group).permit(:name)
  end

  def user_ids
    params[:user_ids].split(',')
  end
end
