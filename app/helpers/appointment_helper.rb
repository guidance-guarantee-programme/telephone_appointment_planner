module AppointmentHelper
  def friendly_options(statuses)
    statuses.map { |k, _| [k.titleize, k] }.to_h
  end

  def rebooked_from_heading(appointment)
    return unless appointment.rebooked_from_id?

    content_tag(
      :h2,
      "Rebooked from ##{appointment.rebooked_from_id}",
      class: 't-original-appointment text-muted'
    )
  end
end
