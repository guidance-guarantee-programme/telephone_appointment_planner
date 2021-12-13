/* global Calendar */
{
  'use strict';

  class MyAppointmentsCalendar extends Calendar {
    start(el) {
      this.config = {
        columnFormat: 'ddd D/M',
        defaultView: 'agendaDay',
        minTime: '08:00:00',
        header: {
          right: 'listWeek agendaDay agendaWeek month today jumpToDate prev,next'
        },
        buttonText: {
          listWeek: 'List'
        },
        nowIndicator: true,
        slotDuration: '00:30:00',
        eventTextColor: '#fff',
        eventDataTransform: this.eventDataTransform,
        eventSources: [
          {
            url: '/appointments?mine',
            cache: true
          },
          {
            url: '/bookable_slots?mine',
            cache: true,
            className: 'fc-bgevent--bookable-slot',
            rendering: 'background',
            eventType: 'slot'
          },
          {
            url: '/holidays?mine',
            className: 'fc-bgevent--holiday',
            rendering: 'background',
            eventType: 'holiday'
          }
        ]
      };

      super.start(el);
    }

    eventRender(event, element, view) {
      super.eventRender(event, element);

      if (event.source.rendering == 'background') {
        return;
      }

      const cancelled = event.status.indexOf('cancelled') > -1 ? true : false;

      if (view.type === 'agendaDay') {
        element.find('.fc-title').html(`
          <span class="glyphicon glyphicon-phone-alt" aria-hidden="true"></span>
          ${event.title} | Phone: ${event.phone} | Memorable word: ${event.memorable_word}
          `);
      }

      if (cancelled) {
        element.find('.fc-title, .fc-list-item-title').append(`
          ${cancelled ? '<span aria-hidden="true">(C)</span><span class="sr-only">Cancelled</span>' : ''}
        `);

        element.addClass('fc-event--cancelled');
      }

      if(event.pensionWise === false) {
        element.addClass('fc-event--due-diligence');
      }
    }

    eventDataTransform(json) {
      json.allDay = false;
      return json;
    }
  }

  window.GOVUKAdmin.Modules.MyAppointmentsCalendar = MyAppointmentsCalendar;
}
