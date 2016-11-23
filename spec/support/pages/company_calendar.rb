module Pages
  class CompanyCalendar < SitePrism::Page
    set_url '/company_calendar'

    element :next_working_day, '.fc-next-button'
    elements :appointments, '.fc-event'
    element(
      :permission_error_message,
      'h1',
      text: /Sorry/
    )
  end
end
