/* global Calendar, moment */
{
  'use strict';

  class GuiderAppointmentsCalendar extends Calendar {
    constructor(el, config = {}) {
      const calendarConfig = $.extend(true, {
        defaultDate: moment(el.data('default-date')),
        columnFormat: 'ddd D/M',
        defaultView: 'agendaDay',
        header: {
          right: 'agendaDay agendaWeek month today prev,next'
        },
        nowIndicator: true,
        slotDuration: '00:30:00',
        eventTextColor: '#fff',
        events: '/appointments',
        eventRender: (event, element, view) => {
          if (view.type === 'agendaDay') {
            element.find('.fc-title').html(`
                <span class="glyphicon glyphicon-phone-alt" aria-hidden="true"></span>
                ${event.title} | Phone: ${event.phone} | Memorable word: ${event.memorable_word}
                `);
          }
        }
      }, config);

      super(el, calendarConfig);
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.GuiderAppointmentsCalendar = GuiderAppointmentsCalendar;
}
