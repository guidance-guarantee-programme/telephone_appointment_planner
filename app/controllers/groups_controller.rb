class GroupsController < ApplicationController
  before_action do
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end

  def index
    @groups = Group.all
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    redirect_to groups_path
  end
end
