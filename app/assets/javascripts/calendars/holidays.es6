/* global Calendar */
{
  'use strict';

  class HolidaysCalendar extends Calendar {
    constructor(el, config = {}) {
      const calendarConfig = $.extend(true, {
        defaultView: 'agendaWeek',
        columnFormat: 'ddd D/M',
        slotDuration: '00:30:00',
        eventBorderColor: '#000',
        events: el.data('holidays-path'),
        header: {
          right: 'agendaDay agendaWeek month today jumpToDate prev,next'
        },
        eventRender: (event, element) => {
          const $button = $(`
            <button class="close t-delete-holiday">
              <span aria-hidden="true">X</span><span class="sr-only">Remove slot</span>
            </button>
          `);

          $button.on('click', () => {
            if (confirm("Are you sure you want to delete this event?")) {
              $.ajax({
                  type: "DELETE",
                  url: this.$el.data('holidays-path') + '/?holiday_ids=' + event.holiday_ids,
                  dataType: "json",
                  complete: () => {
                    this.$el.fullCalendar('removeEvents', event._id);
                  }
              });
            }
          });

          element.append($button);
        },
        views: {
          agendaThreeDay: {
            type: 'agenda',
            duration: { days: 3 }
          }
        }
      }, config);

      super(el, calendarConfig);
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.HolidaysCalendar = HolidaysCalendar;
}
