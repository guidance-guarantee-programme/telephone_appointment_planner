class TagsController < ApplicationController
  before_action do
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end

  def index
    @tags = Tag.all
  end
end
