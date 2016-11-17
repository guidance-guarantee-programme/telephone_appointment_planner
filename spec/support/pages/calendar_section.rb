module Pages
  class CalendarSection < SitePrism::Section
    def holidays
      background_events('holiday')
    end

    def slots
      background_events('slot')
    end

    private

    def background_events(event_type)
      page.evaluate_script(<<-JS).map(&:with_indifferent_access)
        function() {
          var allEvents = $('.t-calendar')
            .fullCalendar('clientEvents');
          return $.grep(allEvents, function(event) {
            return event.source.eventType == '#{event_type}';
          });
        }();
      JS
    end
  end
end
