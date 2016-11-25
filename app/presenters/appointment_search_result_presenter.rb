class AppointmentSearchResultPresenter < SimpleDelegator
  DATE_FORMAT = '%d %B %Y %H:%M'.freeze

  def status
    super.titleize
  end

  def created_at
    super.strftime(DATE_FORMAT)
  end

  def date
    start_at.strftime(DATE_FORMAT)
  end

  def id
    self[:highlighted_id] || super.to_s
  end

  def first_name
    self[:highlighted_first_name] || super
  end

  def last_name
    self[:highlighted_last_name] || super
  end

  def guider_name
    self[:highlighted_name] || guider.name
  end
end
