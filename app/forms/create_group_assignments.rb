class CreateGroupAssignments
  def initialize(user_ids, names)
    @user_ids = user_ids
    @names = names
  end

  def call
    users.each do |user|
      groups.each do |group|
        user.group_assignments.find_or_create_by(group: group)
      end
    end
  end

  private

  def groups
    @groups ||= names.map { |name| Group.find_or_create_by(name: name) }
  end

  def users
    User.find(user_ids)
  end

  attr_reader :user_ids
  attr_reader :names
end
