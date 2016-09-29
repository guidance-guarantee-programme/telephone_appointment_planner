class SchedulePresenter < SimpleDelegator
  def title
    from.strftime('%d %B %Y')
  end

  def self.wrap(objects)
    objects.map { |o| new(o) }
  end
end
