/* global Calendar */
{
  'use strict';

  class GuiderAppointmentsCalendar extends Calendar {
    constructor(el, config = {}) {
      const calendarConfig = $.extend(true, {
        columnFormat: 'ddd D/M',
        defaultView: 'agendaDay',
        header: {
            right: 'agendaDay agendaWeek month today prev,next'
        },
        nowIndicator: true,
        slotDuration: '00:30:00',
        eventTextColor: '#fff',
        events: [
            {
                title: 'Martin Example',
                start: '2016-10-18T08:30:00',
                end: '2016-10-18T09:40:00',
                url: 'https://www.google.com',
                phone: '020 8666 6666',
                memorable_word: 'pension'
            },
            {
                title: 'Julia Default',
                start: '2016-10-18T10:00:00',
                end: '2016-10-18T11:10:00',
                url: 'https://www.google.com',
                phone: '020 8656 6667',
                memorable_word: 'bus'
            },
            {
                title: 'George Blah',
                start: '2016-10-18T14:30:00',
                end: '2016-10-18T15:40:00',
                url: 'https://www.google.com',
                phone: '020 7866 6668',
                memorable_word: 'wow'
            },
            {
                title: 'Ben Bizarre',
                start: '2016-10-18T16:00:00',
                end: '2016-10-18T17:10:00',
                url: 'https://www.google.com',
                phone: '020 3966 6669',
                memorable_word: 'surfing'
            }
        ],
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
