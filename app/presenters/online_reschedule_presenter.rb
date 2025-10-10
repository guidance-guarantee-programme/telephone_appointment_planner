class OnlineReschedulePresenter < SimpleDelegator
  DATE_FORMAT = '%d %B %Y %H:%M'.freeze

  delegate :name, :organisation, to: :previous_guider, prefix: true

  def status
    appointment.status.titleize
  end

  def rescheduled_at
    created_at.in_time_zone('London').strftime(DATE_FORMAT)
  end

  def date
    previous_start_at.strftime(DATE_FORMAT)
  end

  def reference
    appointment.id
  end

  def customer_name
    appointment.name
  end
end
