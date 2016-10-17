/* global Calendar, moment */
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
        defaultDate: moment(el.data('default-date')),
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
          event.$div = $(element);
          element.html(`
            <div style="font-size:18px;">${event.start.format('HH:mm')}</div>
            <span class="glyphicon glyphicon-user" aria-hidden="true"></span> ${event.guiders}
          `);
          element.css({
            'max-width': '46%',
            'padding': '.2em',
            'box-sizing': 'border-box',
            'cursor': 'pointer',
            'background': this.getEventColour(event)
          });
        },
        eventClick: (event) => {
          const events = this.$el.fullCalendar('clientEvents');

          let start = '',
                end = '';

          for (let eventIndex in events) {
            let currentEvent = events[eventIndex];

            if (currentEvent === event && event.selected === false) {
              start = currentEvent.start.format();
              end = currentEvent.end.format();
              currentEvent.selected = true;
            } else {
              currentEvent.selected = false;
            }
          }

          this.$selectedStart.val(start);
          this.$selectedEnd.val(end);

          this.$el.fullCalendar('rerenderEvents');
        }
      }, config);

      super(el, calendarConfig);

      this.coloursConfig = [
        { count: 1,  colour: 'hsl(200, 50%, 65%)' },
        { count: 5,  colour: 'hsl(200, 50%, 55%)' },
        { count: 10, colour: 'hsl(200, 50%, 45%)' },
        { count: 20, colour: 'hsl(200, 50%, 35%)' },
        { count: 30, colour: 'hsl(200, 50%, 25%)' }
      ];

      this.init();
      this.addEvents();
      this.selectEvent();
      this.checkError();
    }

    checkError() {
      if (this.$selectedStart.parents('.field_with_errors').length) {
        $(`#${this.$el.data('error-id')}`).removeClass('hide');
        this.$el.find('.fc-view-container').addClass('error');
      }
    }

    getEventColour(event) {
      if (event.selected === true) {
        return this.selectedEventColour;
      }

      const colours = $.grep(this.coloursConfig, (configItem) => {
        if (configItem.count <= event.guiders) {
          return configItem.colour;
        }
      });

      return colours.pop().colour;
    }

    init() {
      this.$selectedStart = $('[data-selected-start]');
      this.$selectedEnd = $('[data-selected-end]');
      this.selectedEventColour = 'green';
    }

    selectEvent() {
      const events = this.$el.fullCalendar('clientEvents'),
      start = this.$selectedStart.val(),
      end = this.$selectedEnd.val();

      if ((!start && end)) {
        return;
      }

      for (let eventIndex in events) {
        let event = events[eventIndex];

        if (moment(start).isSame(event.start) && moment(end).isSame(event.end)) {
          this.$el.fullCalendar('gotoDate', start);
          event.$div.trigger('click');
          return;
        }
      }
    }

    addEvents() {
      let events = JSON.parse($(this.$el.data('events')).val());

      $.each(events, (index, event) => {
        event.selected = false;
      });

      this.$el.fullCalendar('addEventSource', events);
    }
  }

  window.PWTAP = window.PWTAP || {};
  window.PWTAP.AppointmentAvailabilityCalendar = AppointmentAvailabilityCalendar;
}
