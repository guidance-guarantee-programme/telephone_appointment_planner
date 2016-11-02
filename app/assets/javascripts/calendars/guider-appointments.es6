/* global Calendar */
{
  'use strict';

  class GuiderAppointmentsCalendar extends Calendar {
    constructor(el, config = {}) {
      const calendarConfig = $.extend(true, {
        columnFormat: 'ddd D/M',
        defaultView: 'agendaDay',
        header: {
          right: 'agendaDay agendaWeek month today jumpToDate prev,next'
        },
        nowIndicator: true,
        slotDuration: '00:30:00',
        eventTextColor: '#fff',
        events: '/appointments'
      }, config);

      super(el, calendarConfig);
    }

    eventRender(event, element, view) {
      if (view.type === 'agendaDay') {
        element.find('.fc-title').html(`
            <span class="glyphicon glyphicon-phone-alt" aria-hidden="true"></span>
            ${event.title} | Phone: ${event.phone} | Memorable word: ${event.memorable_word}
            `);
      }

      if (event.status.indexOf('cancelled') > -1) {
        element.addClass('cancelled');
      }
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.GuiderAppointmentsCalendar = GuiderAppointmentsCalendar;
}
