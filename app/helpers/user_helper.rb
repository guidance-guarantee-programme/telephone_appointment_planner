module UserHelper
  def guider_options
    groups = Group.includes(:users)

    {
      'Groups' => group_options(groups),
      'Users'  => user_options
    }
  end

  def group_options(groups)
    groups.map do |group|
      [
        group.name,
        group.name,
        data: {
          icon: 'glyphicon-tag',
          children_to_select: group.user_ids
        }
      ]
    end
  end

  def user_options
    User.guiders.active.reorder(:name).map do |guider|
      [
        guider.name,
        guider.id,
        data: {
          icon: 'glyphicon-user'
        }
      ]
    end
  end
end
