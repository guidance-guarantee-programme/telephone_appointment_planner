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
                start: '2016-10-12T08:30:00',
                end: '2016-10-12T09:40:00',
                url: 'https://www.google.com'
            },
            {
                title: 'Julia Default',
                start: '2016-10-12T10:00:00',
                end: '2016-10-12T11:10:00',
                url: 'https://www.google.com'
            },
            {
                title: 'George Blah',
                start: '2016-10-12T14:30:00',
                end: '2016-10-12T15:40:00',
                url: 'https://www.google.com'
            },
            {
                title: 'Ben Bizarre',
                start: '2016-10-12T16:00:00',
                end: '2016-10-12T17:10:00',
                url: 'https://www.google.com'
            }
        ],
        eventRender: (event, element) => {
          element.find('.fc-title').html(`<span class="glyphicon glyphicon-phone-alt" aria-hidden="true"></span> ${event.title}`);
        }
      }, config);

      super(el, calendarConfig);
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.GuiderAppointmentsCalendar = GuiderAppointmentsCalendar;
}
