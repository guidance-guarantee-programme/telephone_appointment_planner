module Pages
  class NewAppointment < Base
    set_url '/appointments/new{?query*}'

    element :first_name,                            '.t-first-name'
    element :last_name,                             '.t-last-name'
    element :email,                                 '.t-email'
    element :phone,                                 '.t-phone'
    element :mobile,                                '.t-mobile'
    element :date_of_birth_day,                     '.t-date-of-birth-day'
    element :date_of_birth_month,                   '.t-date-of-birth-month'
    element :date_of_birth_year,                    '.t-date-of-birth-year'
    element :memorable_word,                        '.t-memorable-word'
    element :accessibility_requirements,            '.t-accessibility-requirements'

    element :third_party_booked,                    '.t-third-party-booked'
    element :data_subject_name,                     '.t-data-subject-name'
    element :data_subject_date_of_birth_day,        '.t-data-subject-date-of-birth-day'
    element :data_subject_date_of_birth_month,      '.t-data-subject-date-of-birth-month'
    element :data_subject_date_of_birth_year,       '.t-data-subject-date-of-birth-year'
    element :data_subject_consent_obtained,         '.t-data-subject-consent-obtained'
    element :data_subject_consent_evidence,         '.t-data-subject-consent-evidence'
    element :data_subject_consent_evidence_copied,  '.t-copied-evidence'
    element :power_of_attorney,                     '.t-power-of-attorney'
    element :power_of_attorney_evidence,            '.t-power-of-attorney-evidence'
    element :printed_consent_form_required,         '.t-printed-consent-form-required'
    element :printed_consent_form_postcode_lookup,  '.t-printed-consent-form-postcode-lookup'
    element :email_consent_form_required,           '.t-email-consent-form-required'
    element :email_consent,                         '.t-email-consent'

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
    element :address_line_one, '.t-address-line-one'
    element :town, '.t-town'
    element :postcode, '.t-postcode'
    element :smarter_signposted, '.t-smarter-signposted'
    element :bsl_video, '.t-bsl-video'
    element :lloyds_signposted, '.t-lloyds-signposted'

    element :availability_calendar_off, '.t-availability-calendar-off'
    element :availability_calendar_on, '.t-availability-calendar-on'
    element :guider, '.t-guider'
    element :ad_hoc_start_at, '.t-ad-hoc-start-at'

    elements :calendar_events, '.fc-event'

    def ad_hoc_start_at(value)
      execute_script("$('.t-ad-hoc-start-at').val('#{value}')")
    end
  end
end
