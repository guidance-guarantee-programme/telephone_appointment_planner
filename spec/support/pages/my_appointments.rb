module Pages
  class MyAppointments < Base
    set_url '/my_appointments'

    element :next_working_day, '.fc-next-button'

    sections :appointments, '.fc-event' do
      element :title, '.fc-title'
      element :time, '.fc-time'
    end

    section :notification, '.t-notification' do
      element :customer, '.t-customer'
      element :start, '.t-start'
      element :guider, '.t-guider'
    end

    section :calendar, Sections::Calendar, '.t-calendar'
  end
end
