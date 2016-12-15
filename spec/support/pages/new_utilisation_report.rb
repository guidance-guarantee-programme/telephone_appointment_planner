module Pages
  class NewUtilisationReport < Base
    set_url '/utilisation_reports/new'

    element :date_range, '.t-date-range'
    element :download,   '.t-download'

    elements :errors, '.field_with_errors'
  end
end
