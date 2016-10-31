# rubocop:disable Metrics/MethodLength
module Pages
  class ResourceCalendar < SitePrism::Page
    set_url '/resource_calendar'

    elements :guiders, '.fc-resource-cell'
    elements :appointments, '.fc-event'

    section :action_panel, '.t-action-panel' do
      element :save, '.t-save'
    end

    def reschedule(appointment, hours:, minutes:)
      id = appointment['id']

      page.driver.evaluate_script <<-JS
        function() {
          var calendar = $('.js-calendar');
          var event = calendar.fullCalendar('clientEvents', #{id})[0];

          event.start.hours(#{hours}).minutes(#{minutes});
          event.end.hours(#{hours + 1}).minutes(#{minutes});

          calendar.fullCalendar('updateEvent', event);
          calendar.data('loaded-module').handleEventChange(event, function() {});
        }();
      JS
    end

    def find_holiday(holiday)
      page.evaluate_script(<<-JS).with_indifferent_access
        function() {
          return $('.js-calendar')
            .fullCalendar('clientEvents', #{holiday.id})[0];
        }();
      JS
    end
  end
end
