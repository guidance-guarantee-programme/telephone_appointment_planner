module Pages
  class NewAppointment < Base
    set_url '/appointments/new{?query*}'

    elements :slots, '.fc-time-grid-event'

    element :first_name,                            '.t-first-name'
    element :last_name,                             '.t-last-name'
    element :email,                                 '.t-email'
    element :country_of_residence,                  '.t-country-of-residence'
    element :phone,                                 '.t-phone'
    element :mobile,                                '.t-mobile'
    element :date_of_birth_day,                     '.t-date-of-birth-day'
    element :date_of_birth_month,                   '.t-date-of-birth-month'
    element :date_of_birth_year,                    '.t-date-of-birth-year'
    element :memorable_word,                        '.t-memorable-word'
    element :accessibility_requirements,            '.t-accessibility-requirements'
    element :adjustments,                           '.t-adjustments'

    element :welsh,                                 '.t-welsh'
    element :third_party_booked,                    '.t-third-party-booked'
    element :data_subject_name,                     '.t-data-subject-name'
    element :data_subject_date_of_birth_day,        '.t-data-subject-date-of-birth-day'
    element :data_subject_date_of_birth_month,      '.t-data-subject-date-of-birth-month'
    element :data_subject_date_of_birth_year,       '.t-data-subject-date-of-birth-year'

    element :notes,                                 '.t-notes'
    element :gdpr_consent_yes,                      '.t-gdpr-consent-yes'
    element :gdpr_consent_no,                       '.t-gdpr-consent-no'
    element :gdpr_consent_no_response,              '.t-gdpr-consent-no-response'
    element :start_at,                              '.t-start-at', visible: false
    element :end_at,                                '.t-end-at', visible: false
    element :preview_appointment,                   '.t-preview-appointment'
    element :slot_unavailable_message,              '.t-slot-unavailable-message'
    element :original_appointment,                  '.t-original-appointment'
    element :type_of_appointment_standard,          '.t-type-of-appointment-standard'
    element :type_of_appointment_50_54,             '.t-type-of-appointment-50-54'
    element :suggestion,                            '.t-suggestion'
    element :where_you_heard, '.t-where-you-heard'
    element :hidden_where_you_heard, '.t-hidden-where-you-heard', visible: false
    element :referrer, '.t-referrer'
    element :address_line_one, '.t-address-line-one'
    element :town, '.t-town'
    element :postcode, '.t-postcode'
    element :smarter_signposted, '.t-smarter-signposted'
    element :bsl_video, '.t-bsl-video'
    element :lloyds_signposted, '.t-lloyds-signposted'
    element :internal_availability, '.t-internal-availability'
    element :small_pots, '.t-small-pots'
    element :stronger_nudged, '.t-nudge-flag'
    element :attended_digital_yes, '.t-attended-digital-yes'
    element :attended_digital_no, '.t-attended-digital-no'
    element :attended_digital_not_sure, '.t-attended-digital-not-sure'

    element :availability_calendar_off, '.t-availability-calendar-off'
    element :availability_calendar_on, '.t-availability-calendar-on'
    element :guider, '.t-guider'
    element :ad_hoc_start_at, '.t-ad-hoc-start-at'

    elements :calendar_events, '.fc-event'

    elements :fields_with_errors, '.field_with_errors'

    element :due_diligence_banner, '.t-due-diligence-banner'

    element :week_view, '.fc-agendaThreeDay-button'
    element :next_period, '.fc-next-button'

    def ad_hoc_start_at(value)
      execute_script("$('.t-ad-hoc-start-at').val('#{value}')")
    end
  end
end
