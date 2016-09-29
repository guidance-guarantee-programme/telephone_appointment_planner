class TagsController < ApplicationController
  before_action do
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end

  def index
    @tags = Tag.all
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    redirect_to tags_path
  end
end
