module Pages
  class NewUtilisationReport < Base
    set_url '/utilisation_reports/new'

    element :date_range, '.t-date-range'
    element :download,   '.t-download'

    element :pension_wise, '.t-pension-wise'
    element :due_diligence, '.t-due-diligence'

    elements :errors, '.field_with_errors'
  end
end
