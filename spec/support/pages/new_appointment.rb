module Pages
  class NewAppointment < Base
    set_url '/appointments/new'

    element :first_name,                            '.t-first-name'
    element :last_name,                             '.t-last-name'
    element :email,                                 '.t-email'
    element :phone,                                 '.t-phone'
    element :mobile,                                '.t-mobile'
    element :date_of_birth_day,                     '.t-date-of-birth-day'
    element :date_of_birth_month,                   '.t-date-of-birth-month'
    element :date_of_birth_year,                    '.t-date-of-birth-year'
    element :memorable_word,                        '.t-memorable-word'
    element :notes,                                 '.t-notes'
    element :opt_out_of_market_research,            '.t-opt-out-of-market-research'
    element :start_at,                              '.t-start-at', visible: false
    element :end_at,                                '.t-end-at', visible: false
    element :preview_appointment,                   '.t-preview-appointment'
    element :slot_unavailable_message,              '.t-slot-unavailable-message'
    element :original_appointment,                  '.t-original-appointment'
    element :type_of_appointment_standard,          '.t-type-of-appointment-standard'
    element :type_of_appointment_50_54,             '.t-type-of-appointment-50-54'
    element :suggestion,                            '.t-suggestion'
  end
end
