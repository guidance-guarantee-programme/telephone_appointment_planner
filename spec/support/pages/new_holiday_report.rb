module Pages
  class NewHolidayReport < Base
    set_url '/holiday_reports/new'

    element :date_range, '.t-date-range'
    element :download,   '.t-download'

    elements :errors, '.field_with_errors'
  end
end
