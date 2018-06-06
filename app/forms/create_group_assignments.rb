class CreateGroupAssignments
  def initialize(user_ids, names, user)
    @user_ids = user_ids
    @names = names
    @user = user
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
    @groups ||= names.map do |name|
      Group.find_or_create_by(
        name: name,
        organisation_content_id: user.organisation_content_id
      )
    end
  end

  def users
    user.colleagues.find(user_ids)
  end

  attr_reader :user_ids
  attr_reader :names
  attr_reader :user
end
