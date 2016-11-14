module Pages
  class CalendarSection < SitePrism::Section
    def background_events
      page.evaluate_script(<<-JS).map(&:with_indifferent_access)
        function() {
          var allEvents = $('.t-calendar')
            .fullCalendar('clientEvents');
          return $.grep(allEvents, function(event) {
            return event.source.rendering == 'background';
          });
        }();
      JS
    end
  end
end
