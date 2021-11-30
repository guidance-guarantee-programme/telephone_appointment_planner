module Pages
  class NewAppointmentReport < Base
    set_url '/appointment_reports/new'

    element :where,      '.t-where'
    element :date_range, '.t-date-range'
    element :download,   '.t-download'

    element :pension_wise, '.t-pension-wise'
    element :due_diligence, '.t-due-diligence'

    elements :errors, '.field_with_errors'
  end
end
