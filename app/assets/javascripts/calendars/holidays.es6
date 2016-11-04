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
        views: {
          agendaThreeDay: {
            type: 'agenda',
            duration: { days: 3 }
          }
        }
      }, config);

      super(el, calendarConfig);
    }

    eventClick(event) {
      if (!event.bank_holiday) {
        window.location = 'holidays/'+event.holiday_ids+'/edit';
      }
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.HolidaysCalendar = HolidaysCalendar;
}
