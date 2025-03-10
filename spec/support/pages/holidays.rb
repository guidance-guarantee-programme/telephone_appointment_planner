module Pages
  class Holidays < Base
    set_url '/holidays'

    element :flash_of_success, '.alert-success'
    element :next_week, '.fc-next-button'
    element :create_holiday, '.t-create-holiday'
    elements :delete_holidays, '.t-delete-holiday'

    sections :events, '.fc-event' do
      element :title, '.fc-title'
      element :time, '.fc-time'
      element :content, '.fc-content'
    end

    section :calendar, Sections::Calendar, '.t-calendar'
  end
end
