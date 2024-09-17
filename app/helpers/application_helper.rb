module ApplicationHelper
  def paginate(objects, **options)
    options.reverse_merge!(theme: 'twitter-bootstrap-3')
    super(objects, **options)
  end

  def high_priority_activity_count
    Activity
      .high_priority_for(current_user)
      .unresolved
      .count
  end

  def available_slots_path(current_user, schedule_type, rescheduling, appointment_id, rebooking)
    if rebooking && current_user.non_tpas_resource_manager?
      external_bookable_slots_path(schedule_type:, rescheduling:, id: appointment_id, rebooking:)
    else
      available_bookable_slots_path(schedule_type:, rescheduling:, id: appointment_id)
    end
  end
end
