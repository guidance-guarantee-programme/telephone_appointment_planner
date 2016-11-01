class AppointmentCsvPresenter < SimpleDelegator
  DATE_FORMAT = '%d %B %Y %H:%M'.freeze

  def booked_by
    agent.name
  end

  def guider
    super.name
  end

  def date
    start_at
  end

  def duration
    "#{((end_at - start_at) / 1.minute).round} minutes"
  end

  def booking_reference
    id
  end
end
