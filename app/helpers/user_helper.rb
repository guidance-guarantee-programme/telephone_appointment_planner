module UserHelper
  def organisation_options
    [
      ['CAS',  User::CAS_ORGANISATION_ID],
      ['TP',   User::TP_ORGANISATION_ID],
      ['TPAS', User::TPAS_ORGANISATION_ID]
    ]
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
        data: {
          icon: 'glyphicon-tag',
          children_to_select: group.user_ids
        }
      ]
    end
  end

  def user_options(user, scoped: true)
    scope = user.tp_agent? && scoped ? User : user.colleagues

    scope.guiders.active.reorder(:name).map do |guider|
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
