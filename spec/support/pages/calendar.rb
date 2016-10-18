module Pages
  class Calendar < SitePrism::Page
    set_url '/calendar'

    element :next_working_day, '.fc-next-button'

    sections :appointments, '.fc-event' do
      element :title, '.fc-title'
      element :time, '.fc-time'
    end
  end
end
