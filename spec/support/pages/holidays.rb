module Pages
  class Holidays < SitePrism::Page
    set_url 'holidays'
    element(
      :permission_error_message,
      'h1',
      text: 'Sorry, you don\'t seem to have the resource_manager permission for this app.'
    )

    element :next_week, '.fc-next-button'

    sections :appointments, '.fc-event' do
      element :title, '.fc-title'
      element :time, '.fc-time'
    end

    def all_appointments
      wait_for_appointments
      appointments.map do |a|
        {
          title: a.title.text,
          time: a.time.text
        }
      end
    end
  end
end
