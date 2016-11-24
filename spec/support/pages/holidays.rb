module Pages
  class Holidays < SitePrism::Page
    set_url '/holidays'
    element(
      :permission_error_message,
      'h1',
      text: /Sorry/
    )

    element :next_week, '.fc-next-button'
    element :create_holiday, '.t-create-holiday'
    elements :delete_holidays, '.t-delete-holiday'

    sections :events, '.fc-event' do
      element :title, '.fc-title'
      element :time, '.fc-time'
      element :content, '.fc-content'
    end

    def all_events
      wait_until_events_visible
      events.map do |a|
        {
          title: a.title.text,
          time: a.time.text
        }
      end
    end
  end
end
