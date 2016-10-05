class DestroyGroupAssignments
  def initialize(user_ids, group_id)
    @user_ids = user_ids
    @group_id = group_id
  end

  def call
    GroupAssignment
      .where(user_id: user_ids, group_id: group_id)
      .delete_all
  end

  private

  attr_reader :user_ids
  attr_reader :group_id
end
