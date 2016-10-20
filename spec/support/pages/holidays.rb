module Pages
  class Holidays < SitePrism::Page
    set_url '/holidays'
    element(
      :permission_error_message,
      'h1',
      text: 'Sorry, you don\'t seem to have the resource_manager permission for this app.'
    )

    element :next_week, '.fc-next-button'
    element :create_holiday, '.fc-createHoliday-button'
    elements :delete_holidays, '.t-delete-holiday'

    sections :events, '.fc-event' do
      element :title, '.fc-title'
      element :time, '.fc-time'
    end

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
