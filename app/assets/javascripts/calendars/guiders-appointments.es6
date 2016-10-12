/* global Calendar, moment */
{
  'use strict';

  class GuidersAppointmentsCalendar extends Calendar {
    constructor(el, config = {}) {
      const calendarConfig = $.extend(true, {
        columnFormat: 'ddd D/M',
        defaultView: 'agendaDay',
        header: {
            right: 'today prev,next'
        },
        groupByDateAndResource: true,
        nowIndicator: true,
        slotDuration: '00:30:00',
        eventTextColor: '#fff',
        resourceRender: (resourceObj, labelTds) => {
          labelTds.html('');
          $('<div>' + resourceObj.title + '</div>').prependTo(labelTds);
        },
        eventRender: (event, element) => {
          element.html('');

          var resource = el.fullCalendar('getResourceById', event.resourceId);

          element.qtip({
            content: {
              text: `
              <p>${event.start.format('HH:mm')} - ${event.end.format('HH:mm')}</p>
              <p><span class="glyphicon glyphicon-phone-alt" aria-hidden="true"></span> ${event.title}</p>
              <p><span class="glyphicon glyphicon-user" aria-hidden="true"></span> ${resource.title} </p>
              `
            }
          });
        },
        resources: (callback) => {
          var resources = [],
          firstnames = ['Peter', 'Ben', 'George', 'Lucinda', 'David', 'Andrew', 'Jane', 'Matt', 'Aman', 'Will', 'Barbara'],
          surnames = ['Lovell', 'Lucht', 'Singh', 'Barnett', 'Guntrip', 'Vos', 'Smith', 'Jones', 'Brook', 'Williams', 'Taylor', 'Brown', 'Davies', 'Davis'];

          for (let i = 1; i <= 45; i++) {
            var firstname = firstnames[Math.floor(Math.random() * firstnames.length)],
                  surname = surnames[Math.floor(Math.random() * surnames.length)];

            resources.push({
              'id': 'guider_' + i,
              'title': firstname + ' ' + surname
            });
          }

          callback(resources);
        },
        events: (start, end, timezone, callback) => {
          var events = [],
          firstnames = ['Peter', 'Ben', 'George', 'Lucinda', 'David', 'Andrew', 'Jane', 'Matt', 'Aman', 'Will', 'Barbara'],
          surnames = ['Lovell', 'Lucht', 'Singh', 'Barnett', 'Guntrip', 'Vos', 'Smith', 'Jones', 'Brook', 'Williams', 'Taylor', 'Brown', 'Davies', 'Davis'],
          slots = [
            [
              {
                start: '08:30:00',
                end: '09:40:00'
              },
              {
                start: '09:50:00',
                end: '11:00:00'
              },
              {
                start: '11:20:00',
                end: '12:30:00'
              },
              {
                start: '13:30:00',
                end: '14:40:00'
              },
              {
                start: '14:50:00',
                end: '16:00:00'
              }
            ],
            [
              {
                start: '09:30:00',
                end: '10:40:00'
              },
              {
                start: '10:50:00',
                end: '12:00:00'
              },
              {
                start: '12:20:00',
                end: '13:30:00'
              },
              {
                start: '14:30:00',
                end: '15:40:00'
              },
              {
                start: '15:50:00',
                end: '17:00:00'
              }
            ],
            [
              {
                start: '11:00:00',
                end: '12:10:00'
              },
              {
                start: '12:20:00',
                end: '13:30:00'
              },
              {
                start: '13:50:00',
                end: '15:00:00'
              },
              {
                start: '16:00:00',
                end: '17:10:00'
              },
              {
                start: '17:20:00',
                end: '18:30:00'
              }
            ]
          ];

          for (let i = 1; i <= 200; i++) {
            var firstname = firstnames[Math.floor(Math.random() * firstnames.length)],
            surname = surnames[Math.floor(Math.random() * surnames.length)],
            guiderId = Math.floor(Math.random() * 45) + 1,
            guiderSlots = null;

            if (guiderId <= 15) {
              guiderSlots = slots[0];
            }

            if (guiderId > 15 && guiderId <= 30) {
              guiderSlots = slots[1];
            }

            if (guiderId >= 31) {
              guiderSlots = slots[2];
            }

            var slot = guiderSlots[Math.floor(Math.random() * guiderSlots.length)],
            eventStart = moment().format('YYYY-MM-DD') + 'T' + slot.start,
            eventEnd = moment().format('YYYY-MM-DD') + 'T' + slot.end,
            alreadyEvent = false;

            for (var e in events) {
              if (events[e].start < eventEnd && events[e].end > eventStart && events[e].resourceId == 'guider_' + guiderId) {
                alreadyEvent = true;
              }
            }

            if (!alreadyEvent) {
              events.push({
                title: firstname + ' ' + surname,
                start: eventStart,
                end: eventEnd,
                resourceId: 'guider_' + guiderId
              });
            }
          }

          callback(events);
        }
      }, config);

      super(el, calendarConfig);
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.GuidersAppointmentsCalendar = GuidersAppointmentsCalendar;
}
