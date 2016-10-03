class SchedulePresenter < SimpleDelegator
  def title
    format = '%d %B %Y'
    if end_at
      "#{from.strftime(format)} to #{end_at.strftime(format)}"
    else
      from.strftime(format)
    end
  end

  def self.wrap(objects)
    objects.map { |o| new(o) }
  end
end
