module Sections
  class Calendar < SitePrism::Section
    elements :background_events, '.fc-bgevent'
    elements :events, '.fc-event'
    elements :resource_cells, '.fc-resource-cell'

    def holidays
      background_events('holiday')
    end

    def slots
      background_events('slot')
    end

    def guiders
      resource_cells.map(&:text)
    end

    private

    def background_events(event_type)
      page.evaluate_script(<<-JS).map(&:with_indifferent_access)
        function() {
          var $calendar = $('.t-calendar');
          var view = $calendar.fullCalendar('getView');

          var allEvents = $calendar
            .fullCalendar('clientEvents');
          return $.grep(allEvents, function(event) {
            if (event.allDay) {
              return event.start >= view.intervalStart && event.start <= view.intervalEnd;
            } else {
              return event.source.eventType == '#{event_type}' &&
                event.start >= view.intervalStart && event.end <= view.intervalEnd;
            }
          });
        }();
      JS
    end
  end
end
