module Pages
  class NewAppointmentReport < Base
    set_url '/appointment_reports/new'

    element :where,      '.t-where'
    element :date_range, '.t-date-range'
    element :download,   '.t-download'
  end
end
