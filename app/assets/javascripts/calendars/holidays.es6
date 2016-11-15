/* global Calendar */
{
  'use strict';

  class HolidaysCalendar extends Calendar {
    start(el) {
      this.config = {
        defaultView: 'agendaWeek',
        columnFormat: 'ddd D/M',
        slotDuration: '00:30:00',
        eventBorderColor: '#666',
        eventTextColor: '#000',
        events: el.data('holidays-path'),
        header: {
          right: 'agendaDay agendaWeek month today jumpToDate prev,next'
        },
        views: {
          agendaThreeDay: {
            type: 'agenda',
            duration: { days: 3 }
          }
        }
      };

      super.start(el);
    }

    eventRender(event, element) {
      element.addClass('fc-event--holiday');
    }
  }

  window.GOVUKAdmin.Modules.HolidaysCalendar = HolidaysCalendar;
}
