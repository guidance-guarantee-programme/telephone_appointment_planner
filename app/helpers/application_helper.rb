module ApplicationHelper
  def paginate(objects, options = {})
    options.reverse_merge!(theme: 'twitter-bootstrap-3')
    super(objects, options)
  end

  def high_priority_activity_count
    Activity
      .high_priority_for(current_user)
      .unresolved
      .count
  end
end
