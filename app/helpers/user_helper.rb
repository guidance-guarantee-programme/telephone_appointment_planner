module UserHelper
  def psg_banner(guider)
    return unless guider.due_diligence?

    content_tag(:small, ' (PSG)')
  end

  def can_switch_availability?(current_user, appointment, rebooking, rescheduling)
    return false unless appointment.pension_wise?
    return true if current_user.tpas_agent? && !rescheduling
    return true if current_user.non_tpas_resource_manager? && rebooking

    false
  end

  def can_process?(current_user, appointment)
    !current_user.tpas? && !appointment.processed_at?
  end

  def organisation_options(current_user)
    Provider.all(current_user).map do |organisation|
      [organisation.name, organisation.id]
    end
  end

  def guider_options(user, include_reset: true)
    groups = Group.for_user(user).includes(:users)

    options = include_reset ? { 'Reset' => reset_options } : {}
    options['Groups'] = group_options(groups)
    options['Users']  = user_options(user)
    options
  end

  def reset_options
    [
      [
        'Reset all filters',
        'Reset all filters',
        { data: { icon: 'glyphicon-remove', children_to_select: [] } }
      ]
    ]
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

  def user_options(user, scoped: true, except: nil)
    scope = user.tp_agent? && scoped ? User : user.colleagues

    scope.guiders.active.reorder(:name).map do |guider|
      next if guider.id == except

      [guider.name, guider.id, { data: { icon: 'glyphicon-user' } }]
    end
  end
end
