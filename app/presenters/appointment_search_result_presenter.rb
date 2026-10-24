class AppointmentSearchResultPresenter < SimpleDelegator
  DATE_FORMAT = '%d %B %Y %H:%M'.freeze

  delegate :name, :organisation, to: :guider, prefix: true
  delegate :name, :organisation, to: :previous_guider, prefix: true

  def status
    super&.titleize
  end

  def created_at
    super.strftime(DATE_FORMAT)
  end

  def rescheduled_at
    super.in_time_zone('London').strftime(DATE_FORMAT)
  end

  def date
    start_at.strftime(DATE_FORMAT)
  end
end
