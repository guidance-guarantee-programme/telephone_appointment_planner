module Sections
  class Calendar < SitePrism::Section
    elements :background_events, '.fc-bgevent'
    elements :events, '.fc-event'
    elements :resource_cells, '.fc-resource-cell'

    def appointments
      background_events('appointment')
    end

    def holidays
      background_events('holiday')
    end

    def slots
      background_events('slot')
    end

    def guiders
      wait_until_resource_cells_visible

      resource_cells.map(&:text)
    end

    def find_holiday_by_id(id)
      page.evaluate_script(<<-JS).with_indifferent_access
        function() {
          return $('.t-calendar')
            .fullCalendar('clientEvents', #{id})[0];
        }();
      JS
    end

    def select_holiday_range(resource_name) # rubocop:disable Metrics/MethodLength
      wait_until_rendered

      x, y = page.driver.evaluate_script <<-JS
        function() {
          var $calendar = $('.t-calendar');
          var $header = $calendar.find(".fc-resource-cell:contains('#{resource_name}')");
          if ($header.length > 0) {
            var $row = $calendar.find('[data-time="09:00:00"]');
            return [$header.offset().left + 5, $row.offset().top + 5];
          }
        }();
      JS

      page.driver.click(x, y)
    end

    private

    def background_events(event_type)
      wait_until_rendered

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

    def wait_until_rendered
      find('.t-full-calendar-rendered', visible: false, minimum: 1)
    end
  end
end
