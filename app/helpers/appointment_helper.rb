module AppointmentHelper
  def processed_tick(appointment)
    return unless appointment.processed_at?

    content_tag(:span, '', class: 'glyphicon glyphicon-ok t-processed text-muted', title: 'Processed')
  end

  def display_with_newline(value)
    safe_join([value, tag.br]) if value.present?
  end

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
