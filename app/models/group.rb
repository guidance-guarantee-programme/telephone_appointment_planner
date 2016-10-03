class Group < ApplicationRecord
  default_scope { order(:name) }

  has_many :group_assignments
  has_many :users, through: :group_assignments

  def self.assigned_to(user_ids)
    includes(:group_assignments)
      .where(group_assignments: { user_id: user_ids })
      .select('distinct on (groups.name) groups.*')
  end
end
