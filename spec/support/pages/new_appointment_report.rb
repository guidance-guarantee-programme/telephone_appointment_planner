module Pages
  class NewAppointmentReport < SitePrism::Page
    set_url '/appointment_reports/new'

    element(
      :permission_error_message,
      'h1',
      text: /Sorry/
    )

    element :where,      '.t-where'
    element :date_range, '.t-date-range'
    element :download,   '.t-download'
  end
end
