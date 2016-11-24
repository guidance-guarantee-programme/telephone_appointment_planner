module Pages
  class NewUtilisationReport < SitePrism::Page
    set_url '/utilisation_reports/new'

    element(
      :permission_error_message,
      'h1',
      text: /Sorry/
    )

    element :date_range, '.t-date-range'
    element :download,   '.t-download'
  end
end
