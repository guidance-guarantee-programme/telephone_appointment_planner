module Pages
  class NewHoliday < SitePrism::Page
    set_url 'holidays/new'

    element :create_holiday, '.fc-createHoliday-button'
    element :save, '.t-save'

    sections :events, '.fc-event' do
      element :title, '.fc-title'
      element :time, '.fc-time'
    end

    element :title, '.t-title'
    element :date_range, '.t-date-range'
    elements :guider_checkboxes, '.t-checkbox'

    def all_events
      wait_for_events
      events.map do |a|
        {
          title: a.title.text,
          time: a.time.text
        }
      end
    end
  end
end
