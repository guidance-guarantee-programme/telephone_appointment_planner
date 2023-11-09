module UserHelper
  def can_process?(current_user, appointment)
    !current_user.tpas? && !appointment.processed_at?
  end

  def organisation_options(current_user)
    Provider.all(current_user).map do |organisation|
      [organisation.name, organisation.id]
    end
  end

  def guider_options(user)
    groups = Group.for_user(user).includes(:users)

    {
      'Groups' => group_options(groups),
      'Users'  => user_options(user)
    }
  end

  def group_options(groups)
    groups.map do |group|
      [
        group.name,
        group.name,
        { data: {
          icon: 'glyphicon-tag',
          children_to_select: group.user_ids
        } }
      ]
    end
  end

  def user_options(user, scoped: true)
    scope = user.tp_agent? && scoped ? User : user.colleagues

    scope.guiders.active.reorder(:name).map do |guider|
      [
        guider.name,
        guider.id,
        { data: {
          icon: 'glyphicon-user'
        } }
      ]
    end
  end
end
