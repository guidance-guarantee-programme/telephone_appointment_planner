/* global Calendar */
{
  'use strict';

  class HolidaysCalendar extends Calendar {
    start(el) {
      this.config = {
        defaultView: 'agendaWeek',
        columnFormat: 'ddd D/M',
        slotDuration: '00:30:00',
        allDaySlot: true,
        eventBorderColor: '#666',
        eventTextColor: '#000',
        eventSources: [
          {
            url: '/holidays/merged',
            className: 'fc-event--holiday',
            eventType: 'holiday'
          }
        ],
        header: {
          right: 'agendaDay agendaWeek listCustom month today jumpToDate prev,next'
        },
        views: {
          listCustom: {
            type: 'list',
            duration: { years: 1 },
            buttonText: 'List'
          }
        }
      };

      super.start(el);
    }

    eventAfterRender(event, element) {
      if(event.multipleGuiders === true) {
        element.addClass('fc-event--multiple-guiders');
      }
    }
  }

  window.GOVUKAdmin.Modules.HolidaysCalendar = HolidaysCalendar;
}
