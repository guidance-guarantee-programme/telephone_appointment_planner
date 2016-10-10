/* global Calendar */
{
  'use strict';

  class AppointmentAvailabilityCalendar extends Calendar {
    constructor(el, config = {}) {
      const calendarConfig = $.extend(true, {
        defaultView: 'agendaWeek',
        weekends: false,
        columnFormat: 'ddd D/M',
        slotDuration: '00:30:00',
        eventBorderColor: '#000',
        header: {
          'right': 'agendaWeek agendaThreeDay agendaDay today prev,next'
        },
        views: {
          agendaThreeDay: {
            type: 'agenda',
            duration: { days: 3 }
          }
        },
        eventRender: (event, element) => {
          element.html(`
            <div style="font-size:18px;">${event.start.format('HH:mm')}</div>
            <span class="glyphicon glyphicon-user" aria-hidden="true"></span> ${event.guiders}
          `);
          element.css({
            'max-width': '46%',
            'padding': '.2em',
            'box-sizing': 'border-box',
            'cursor': 'pointer'
          });
        },
        eventClick: (event) => {
          const events = this.$el.fullCalendar('clientEvents'),
                currentBackgroundColor = event.backgroundColor;

          let start = '',
                end = '';

          for (let eventIndex in events) {
            let currentEvent = events[eventIndex];
            currentEvent.backgroundColor = this.defaultEventColour;
          }

          event.backgroundColor = (currentBackgroundColor == this.selectedEventColour) ? this.defaultEventColour : this.selectedEventColour;

          if (event.backgroundColor == this.selectedEventColour) {
            start = event.start.format();
            end = event.end.format();
          }

          this.$selectedStart.val(start);
          this.$selectedEnd.val(end);

          this.$el.fullCalendar('rerenderEvents');
        }
      }, config);

      super(el, calendarConfig);

      this.init();
      this.addEvents();
    }

    init() {
      this.$selectedStart = $('[data-selected-start]');
      this.$selectedEnd = $('[data-selected-end]');
      this.defaultEventColour = '#3a87ad';
      this.selectedEventColour = 'green';
    }

    addEvents() {
      this.$el.fullCalendar('addEventSource', JSON.parse($(this.$el.data('events')).val()));
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.AppointmentAvailabilityCalendar = AppointmentAvailabilityCalendar;
}
