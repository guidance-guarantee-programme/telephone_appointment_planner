class DestroyGroupAssignments
  def initialize(user_ids, group_id)
    @user_ids = user_ids
    @group_id = group_id
  end

  def call
    GroupAssignment
      .where(user_id: user_ids, group_id: group_id)
      .delete_all

    destroy_orphaned_group
  end

  private

  attr_reader :user_ids
  attr_reader :group_id

  def destroy_orphaned_group
    group = Group.find(group_id)
    group.destroy if group.group_assignments.none?
  end
end
