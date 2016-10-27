class AppointmentPresenter < SimpleDelegator
  DATE_FORMAT = '%d %B %Y %H:%M'.freeze

  def status
    super.titleize
  end

  def date
    start_at.strftime(DATE_FORMAT)
  end
end
