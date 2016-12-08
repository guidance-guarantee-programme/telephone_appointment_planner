module UserHelper
  def guider_options
    groups = Group.includes(:users)

    {
      'Groups': groups.map do |group|
        [group.name, group.name, data: { icon: 'glyphicon-tag', children_to_select: group.user_ids }]
      end,
      'Users': User.guiders.active.map do |guider|
        [guider.name, guider.id, data: { icon: 'glyphicon-user' }]
      end
    }
  end
end
