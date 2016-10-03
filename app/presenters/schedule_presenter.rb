class SchedulePresenter < SimpleDelegator
  def title
    format = '%d %B %Y'
    if end_at
      "#{start_at.strftime(format)} to #{end_at.strftime(format)}"
    else
      start_at.strftime(format)
    end
  end

  def self.wrap(objects)
    objects.map { |o| new(o) }
  end
end
