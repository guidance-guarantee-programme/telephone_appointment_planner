module ApplicationHelper
  def paginate(objects, options = {})
    options.reverse_merge!(theme: 'twitter-bootstrap-3')
    super(objects, options)
  end

  def high_priority_activity_count
    current_user
      .activities
      .high_priority
      .unresolved
      .count
  end
end
