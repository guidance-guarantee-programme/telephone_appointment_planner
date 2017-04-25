module Pages
  class CompanyCalendar < Base
    set_url '/company_calendar'

    element :date, '.fc-left h2'
    element :next_week_day, '.fc-next-button'
    elements :appointments, '.fc-event'

    section :calendar, Sections::Calendar, '.t-calendar'
  end
end
