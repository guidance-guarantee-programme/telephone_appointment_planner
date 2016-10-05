class CreateGroupAssignments
  def initialize(user_ids, name)
    @user_ids = user_ids
    @name = name
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

  attr_reader :user_ids
  attr_reader :name
end
