class CreateGroupAssignments
  include ActiveModel::Model

  attr_accessor :user_ids
  attr_accessor :name

  def initialize(user_ids, group_params)
    @user_ids = user_ids
    super(group_params)
  end

  def call
    @group = Group.find_or_create_by(name: name)

    users.each do |user|
      user.group_assignments.find_or_create_by(group: @group)
    end
  end

  private

  def users
    User.find(user_ids)
  end
end
