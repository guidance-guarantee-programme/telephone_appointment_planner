module Pages
  class NewAppointmentReport < SitePrism::Page
    set_url '/appointment_reports/new'

    element(
      :permission_error_message,
      'h1',
      text: 'Sorry, you don\'t seem to have the resource_manager permission for this app.'
    )

    element :where,      '.t-where'
    element :date_range, '.t-date-range'
    element :download,   '.t-download'
  end
end
