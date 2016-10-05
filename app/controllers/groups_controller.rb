class GroupsController < ApplicationController
  before_action do
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end

  def index
    @guiders = User.find(user_ids)
    @groups  = Group.assigned_to(user_ids)
  end

  def create
    CreateGroupAssignments.new(user_ids, group_params).call

    redirect_back(
      fallback_location: users_path,
      success: 'The users were assigned to the specified groups'
    )
  end

  def destroy
    DestroyGroupAssignments.new(user_ids, params[:id]).call

    redirect_back(
      fallback_location: users_path,
      success: 'The users were removed from the specified groups'
    )
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end

  def user_ids
    params[:user_ids].split(',')
  end
end
