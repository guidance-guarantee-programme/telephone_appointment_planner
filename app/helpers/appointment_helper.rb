module AppointmentHelper
  def due_diligence_grace_period
    BookableSlot
      .next_valid_start_date(nil, User::DUE_DILIGENCE_SCHEDULE_TYPE)
      .to_date
      .next_day
      .to_s(:govuk_date)
  end

  def bsl_video_visible?(current_user)
    current_user.administrator? || current_user.tp? || current_user.lancs_west?
  end

  def bsl_video_disabled?(current_user)
    return false if current_user.administrator? || current_user.lancs_west?

    true
  end

  def boolean_yes_no(value)
    value ? 'Yes' : 'No'
  end

  def display_dc_pot_unsure_banner?(appointment)
    return if appointment.dc_pot_confirmed?
    return if appointment.tp_guider? || appointment.tpas_guider?

    true
  end

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
