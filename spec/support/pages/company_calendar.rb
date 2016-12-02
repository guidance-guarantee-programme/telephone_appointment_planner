module Pages
  class CompanyCalendar < Base
    set_url '/company_calendar'

    element :next_working_day, '.fc-next-button'
    elements :appointments, '.fc-event'

    section :calendar, Sections::Calendar, '.t-calendar'
  end
end
