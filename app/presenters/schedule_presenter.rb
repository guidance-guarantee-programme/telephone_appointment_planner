class SchedulePresenter < SimpleDelegator
  DATE_FORMAT = '%d %B %Y'.freeze

  def title
    if start_at && end_at
      "#{start_at.strftime(DATE_FORMAT)} to #{end_at.strftime(DATE_FORMAT)}"
    elsif start_at
      "#{start_at.strftime(DATE_FORMAT)} onwards"
    end
  end

  def self.wrap(objects)
    objects.map { |o| new(o) }
  end
end
