module AppointmentHelper
  def summary_prompt_data(appointment)
    return {} unless appointment.summarised?

    {}.tap do |prompt|
      prompt[:confirm] = 'Completing the Summary Document Generator will result in a newly issued summary document. ' \
                         'Are you sure?'
    end
  end

  def country_name(code)
    country = ISO3166::Country[code]
    country.translations[I18n.locale.to_s]
  end

  def due_diligence_grace_period
    grace = BookableSlot.next_valid_start_date(nil, User::DUE_DILIGENCE_SCHEDULE_TYPE)

    grace = grace.next_day if grace.hour > 20

    grace.to_date.to_s(:govuk_date)
  end

  def welsh_visible?(current_user)
    current_user.cardiff_and_vale?
  end

  def stronger_nudge_visible?(current_user, appointment)
    (current_user.tp_agent? || current_user.tpas_agent?) && appointment.pension_wise?
  end

  def bsl_video_visible?(current_user)
    current_user.administrator? || current_user.tp? || current_user.lancashire_west? || current_user.tpas_agent?
  end

  def bsl_video_disabled?(current_user)
    return false if current_user.administrator? || current_user.lancashire_west?

    true
  end

  def boolean_yes_no(value)
    value ? 'Yes' : 'No'
  end

  def display_nudge_eligibility?(appointment)
    appointment.nudged? && appointment.age_at_appointment < 50
  end

  def nudge_banner_text(appointment)
    "Customer aged under 50 and eligible due to #{appointment.nudge_eligibility_reason.humanize}"
  end

  def display_dc_pot_unsure_banner?(appointment)
    !appointment.dc_pot_confirmed?
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
