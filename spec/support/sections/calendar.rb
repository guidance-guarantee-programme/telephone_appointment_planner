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
      evaluate_script(<<-JS).with_indifferent_access
        function() {
          return $('.t-calendar')
            .fullCalendar('clientEvents', #{id})[0];
        }();
      JS
    end

    def select_holiday_range(resource_name)
      wait_until_rendered

      x, y = evaluate_script <<-JS
        function() {
          var $calendar = $('.t-calendar');
          var $header = $calendar.find(".fc-resource-cell:contains('#{resource_name}')");
          if ($header.length > 0) {
            var $row = $calendar.find('[data-time="09:00:00"]');
            return [$header.offset().left + 10, $row.offset().top + 20];
          }
        }();
      JS

      parent.find('body').click(x: x.to_i, y: y.to_i)
    end

    private

    def background_events(event_type)
      wait_until_rendered

      evaluate_script(<<-JS).map(&:with_indifferent_access)
        function() {
          var $calendar = $('.t-calendar');
          var view = $calendar.fullCalendar('getView');

          var allEvents = $calendar.fullCalendar('clientEvents');

          $.grep(allEvents, function(event) {
            if (event.allDay) {
              return event.start >= view.intervalStart && event.start <= view.intervalEnd;
            } else {
              return event.source.eventType == '#{event_type}' &&
                event.start >= view.intervalStart && event.end <= view.intervalEnd;
            }
          });

          return $.map(allEvents, function(event) {
            if (('holiday' == '#{event_type}' || 'slot' == '#{event_type}') && $.isFunction(event.start.format)) {
              event.start = event.start.format();
              event.end = event.end.format();
            }

            return event;
          })
        }();
      JS
    end

    def wait_until_rendered
      Timeout.timeout(Capybara.default_max_wait_time) do
        loop until evaluate_script('jQuery.active').zero?
      end
    end
  end
end
